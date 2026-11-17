#!/usr/bin/env python3
"""Master package catalog: validate, render manifests, and report profile readiness.

Stdlib only. Never installs packages, calls pacman, or downloads remote code.
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "packages/master-catalog.json"
NAME = re.compile(r"^[a-z0-9][a-z0-9._+\-]*$")


def load():
    return json.loads(CATALOG.read_text(encoding="utf-8"))


def validate(data):
    issues = []
    if data.get("schema_version") != 1:
        issues.append("unexpected schema version")
    profiles = data.get("profiles", {})
    packages = data.get("packages", [])
    seen = set()
    group = {key: [] for key in profiles}
    for i, item in enumerate(packages):
        pid, name = item.get("id", ""), item.get("package_name")
        kind, profile = item.get("kind"), item.get("profile")
        if not NAME.fullmatch(pid):
            issues.append(f"invalid ID at index {i}: {pid}")
        if pid in seen:
            issues.append(f"duplicate package: {pid}")
        seen.add(pid)
        if profile not in profiles and kind == "native":
            issues.append(f"unknown native profile: {pid}/{profile}")
        if not item.get("source_url", "").startswith(("https://", "http://")):
            issues.append(f"missing documented source: {pid}")
        if not item.get("owner", "").startswith("rf-"):
            issues.append(f"missing RF owner: {pid}")
        if kind == "native":
            if not isinstance(name, str) or not NAME.fullmatch(name):
                issues.append(f"invalid native package name: {pid}")
            if item.get("source") != "pacman-sync-database":
                issues.append(f"native package must use pacman: {pid}")
            if item.get("status") not in {"CANDIDATE_UNVERIFIED", "PACKAGE_RESOLVED", "HOST_PASS", "BLOCKED"}:
                issues.append(f"invalid native status: {pid}")
            if profile in group:
                group[profile].append(name)
        elif kind == "manual-review":
            if name is not None or item.get("install_default") or not item.get("review_required"):
                issues.append(f"manual package cannot autoinstall: {pid}")
            if item.get("status") != "MANUAL_REVIEW_REQUIRED":
                issues.append(f"manual package status mismatch: {pid}")
        else:
            issues.append(f"invalid package kind: {pid}")
    for profile, config in profiles.items():
        if profile not in {"core", "sdr", "ham", "desktop"}:
            issues.append(f"unsupported deploy profile: {profile}")
        if config.get("manifest") != f"packages/{profile}.txt":
            issues.append(f"manifest path mismatch: {profile}")
        if len(group[profile]) != len(set(group[profile])):
            issues.append(f"duplicate package within profile: {profile}")
    if not data.get("deployment_contract", {}).get("manual_review_never_autoinstall"):
        issues.append("manual review safety policy missing")
    if not data.get("deployment_contract", {}).get("no_transmit_by_default"):
        issues.append("RX-first safety policy missing")
    return issues


def profile_lines(data, profile):
    selected = [p["package_name"] for p in data["packages"]
                if p["kind"] == "native" and p["profile"] == profile]
    return "# Generated from packages/master-catalog.json; do not edit directly.\n" + "\n".join(selected) + "\n"


def compare_manifests(data):
    issues = []
    for profile, definition in data["profiles"].items():
        path = ROOT / definition["manifest"]
        if not path.is_file():
            issues.append(f"missing {path.relative_to(ROOT)}")
            continue
        got = []
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.split("#", 1)[0].strip()
            if line:
                got.append(line)
        expected = [p["package_name"] for p in data["packages"]
                    if p["kind"] == "native" and p["profile"] == profile]
        if got != expected:
            issues.append(f"manifest differs from master catalog: {profile}")
    return issues


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["validate", "render", "summary"])
    parser.add_argument("--check", action="store_true", help="also verify manifests match catalog")
    args = parser.parse_args()
    data = load()
    issues = validate(data)
    if not issues and args.action == "validate" and args.check:
        issues += compare_manifests(data)
    if issues:
        for issue in issues:
            print("FAIL:", issue, file=sys.stderr)
        raise SystemExit(1)
    if args.action == "render":
        for profile, item in data["profiles"].items():
            path = ROOT / item["manifest"]
            path.write_text(profile_lines(data, profile), encoding="utf-8")
            print("RENDER:", path.relative_to(ROOT))
    elif args.action == "summary":
        for profile in data["profiles"]:
            count = sum(p["kind"] == "native" and p["profile"] == profile for p in data["packages"])
            print(f"{profile}: {count} native package candidates")
        print("manual-review:", sum(p["kind"] == "manual-review" for p in data["packages"]))
    else:
        print("PASS: master catalog integrity" + (" and manifest alignment" if args.check else ""))


if __name__ == "__main__":
    main()
