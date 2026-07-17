from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
ROOT = TOOLS.parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from estudio_governance import parse_metadata  # noqa: E402

EVIDENCE_TOOL = TOOLS / "create_evidence_manifest.py"
LFS_TOOL = TOOLS / "register_new_lfs_path.ps1"
SECRET_TOOL = TOOLS / "check_secret_scan.ps1"
POWERSHELL = shutil.which("powershell.exe") or shutil.which("powershell")


def git(root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", "-C", str(root), *args], text=True, capture_output=True, check=True)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class ProductionSafetyDocumentTests(unittest.TestCase):
    documents = [
        ROOT / "08_Coordenacao_Agentes/Runbooks/VISUAL_PRODUCTION_PIPELINE.md",
        ROOT / "08_Coordenacao_Agentes/Registers/code-convergence-candidates-v1.md",
        ROOT / "08_Coordenacao_Agentes/Registers/cleanup-retention-manifest-v1.md",
        ROOT / "08_Coordenacao_Agentes/Templates/Asset_Provenance_TEMPLATE.md",
        ROOT / "08_Coordenacao_Agentes/Templates/Documentation_Cleanup_Manifest_TEMPLATE.md",
        ROOT / "08_Coordenacao_Agentes/Templates/Code_Convergence_Candidate_Receipt_TEMPLATE.md",
        ROOT / "canon/studio-conventions/prospective-asset-provenance.md",
        ROOT / "canon/studio-conventions/final-focus-readiness.md",
        ROOT / "canon/studio-conventions/code-convergence-registry.md",
    ]

    def test_new_documents_have_governance_metadata(self) -> None:
        required = {"status", "authority", "last_verified", "review_when", "supersedes", "superseded_by"}
        allowed = {"operational_contract", "historical_record", "runbook"}
        for path in self.documents:
            with self.subTest(path=path):
                metadata = parse_metadata(path.read_text(encoding="utf-8"))
                self.assertTrue(required.issubset(metadata))
                self.assertIn(metadata["authority"], allowed)

    def test_final_focus_is_explicitly_inactive(self) -> None:
        text = (ROOT / "canon/studio-conventions/final-focus-readiness.md").read_text(encoding="utf-8")
        self.assertIn("activation_state: `not_activated`", text)
        self.assertIn("selected_project: `none`", text)
        self.assertIn("release_authority: `not_authorized`", text)

    def test_convergence_registry_matches_five_observed_groups(self) -> None:
        groups = [
            (
                "361e6edae17601f5e027f04e628139c668868ba69ba0c06b376aa16dd74c5796",
                "Projetos/draxos-roguelike-cardgame/ui/controls/deck_slot_control.gd",
                "Projetos/rpg-turnos/ui/controls/deck_slot_control.gd",
            ),
            (
                "a895a3c763b3268f892273a862e1e0175828041a216a5b195898b2b6a10d18b1",
                "Projetos/draxos-roguelike-cardgame/core/ui_tokens.gd",
                "Projetos/rpg-turnos/core/ui_tokens.gd",
            ),
            (
                "e91818d34f3a3a212df55bd58952aeb5673bea5fdc327b773bc457fa3a91020b",
                "Projetos/draxos-roguelike-cardgame/ui/controls/enemy_hero_drop_zone.gd",
                "Projetos/rpg-turnos/ui/controls/enemy_hero_drop_zone.gd",
            ),
            (
                "70cb0185c6e7ca34a83ce58c9fc6bdde6d2da139f620c2b4bcbce267c7e310cb",
                "Projetos/draxos-roguelike-cardgame/ui/controls/card_pool_drop_zone.gd",
                "Projetos/rpg-turnos/ui/controls/card_pool_drop_zone.gd",
            ),
            (
                "7e0625601dfac256c259f1daa02f8d24fdcf160722e77752a46bdb4996eccd9b",
                "Projetos/FpsPlayground/tools/create_bootstrap_scene.gd",
                "Projetos/JogoDaCopa/tools/create_bootstrap_scene.gd",
            ),
        ]
        registry = (ROOT / "08_Coordenacao_Agentes/Registers/code-convergence-candidates-v1.md").read_text(encoding="utf-8")
        self.assertEqual(5, registry.count("status: `candidate/deferred`"))
        for expected, first, second in groups:
            with self.subTest(first=first):
                self.assertEqual(expected, digest(ROOT / first))
                self.assertEqual(expected, digest(ROOT / second))
                self.assertIn(expected, registry)
                self.assertIn(first, registry)
                self.assertIn(second, registry)
        self.assertNotEqual(
            groups[1][0],
            digest(ROOT / "Projetos/draxos-mobile/core/ui_tokens.gd"),
        )

    def test_cleanup_registry_preserves_all_measured_large_duplicates(self) -> None:
        groups = [
            ("0baa5b456f27caeba7677c6e7e9c18a8fc22692208592ad11ba30212d7edc284", "Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-first-minute-fa82cb7d.png", "Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-night-evidence-fa82cb7d.png"),
            ("1028b1e0b9e1ee40c9ef144db7de9af639f034bbc4850fe16ad94daec9464723", "Projetos/draxos-mobile/assets/ux_overhaul/entry_necromante.png", "Projetos/draxos-roguelike-cardgame/assets/ui/characters/Necromante.png"),
            ("9317f9c3c7f45325183876b8600e98038b30eca3fa1cab5f12e3d81cb1532f9b", "Projetos/draxos-mobile/assets/ux_overhaul/refuge_ship_hub.png", "Projetos/draxos-roguelike-cardgame/assets/ui/backgrounds/ship_hub_background.png"),
            ("57fd0ad8c96a4d01b38769637e066cecaa285b456f6e48ce00863754a457affb", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_1_Normal_png.png", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_1_Normal.png"),
            ("bc7aa863bd22ab0a995cd838cceb4d3a5186ee54ee2fb0108fad85d20c057e6e", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_1_BaseColor.png", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_1_BaseColor.png"),
            ("172f230aae0d4366c3cfc0402b2e6d1811b11f8487344bff28605eeacac1558d", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_2_Normal.png", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_2_Normal.png"),
            ("f9f4f2fb3eeeefb0b6f0fdef38b0770fd6607640c1c680b8139dd76697e9f9b3", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_2_BaseColor.png", "Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_2_BaseColor.png"),
            ("6bc984ac8cb997ad213f491d31dfae3ce3f3b0a3507abd85b390b8a26176d8ba", "Projetos/draxos-mobile/docs/battle-lab/generated/battle_lab_summary.json", "Projetos/draxos-mobile/docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01/battle_lab_summary.json"),
            ("fb845708f301d60f19a23a0b1276dd2d4d7c85964f4455d8d840263f1aac9b29", "Projetos/draxos-mobile/docs/battle-lab/generated/battle_lab_matchups.csv", "Projetos/draxos-mobile/docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01/battle_lab_matchups.csv"),
        ]
        manifest = (ROOT / "08_Coordenacao_Agentes/Registers/cleanup-retention-manifest-v1.md").read_text(encoding="utf-8")
        self.assertIn("destructive_authorization: `not_authorized`", manifest)
        for expected, first, second in groups:
            with self.subTest(first=first):
                self.assertEqual(expected, digest(ROOT / first))
                self.assertEqual(expected, digest(ROOT / second))
                self.assertIn(expected, manifest)
                self.assertIn(first, manifest)
                self.assertIn(second, manifest)


class EvidenceManifestToolTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.bundle = self.root / "evidence/task-1"
        self.bundle.mkdir(parents=True)
        (self.bundle / "capture.png").write_bytes(b"not-a-real-png-but-stable")
        (self.bundle / "report.json").write_text('{"result":"pass"}\n', encoding="utf-8")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_tool(self, *extra: str) -> subprocess.CompletedProcess[str]:
        command = [
            sys.executable,
            str(EVIDENCE_TOOL),
            "--root", str(self.root),
            "--bundle", "evidence/task-1",
            "--project", "JogoDaCopa",
            "--task-id", "task-1",
            "--source-sha", "a" * 40,
            "--file", "capture.png",
            "--file", "report.json",
            "--canonical", "capture.png",
            *extra,
        ]
        return subprocess.run(command, text=True, capture_output=True, check=False)

    def test_dry_run_prints_schema_manifest_without_writing(self) -> None:
        result = self.run_tool()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertFalse((self.bundle / "manifest.json").exists())
        manifest = json.loads(result.stdout)
        self.assertEqual("estudio_evidence_v1", manifest["schema"])
        self.assertEqual("image", manifest["files"][0]["role"])
        self.assertEqual(digest(self.bundle / "capture.png"), manifest["files"][0]["sha256"])
        self.assertIn("mode=dry-run", result.stderr)

    def test_write_creates_new_manifest_and_refuses_overwrite(self) -> None:
        result = self.run_tool("--write")
        self.assertEqual(0, result.returncode, result.stderr)
        manifest_path = self.bundle / "manifest.json"
        self.assertTrue(manifest_path.is_file())
        self.assertEqual(json.loads(result.stdout), json.loads(manifest_path.read_text(encoding="utf-8")))
        second = self.run_tool("--write")
        self.assertEqual(2, second.returncode)
        self.assertIn("overwrite is not supported", second.stderr)

    def test_rejects_traversal_and_glob_paths(self) -> None:
        for unsafe in ("../escape.txt", "*.png"):
            command = [
                sys.executable, str(EVIDENCE_TOOL), "--root", str(self.root),
                "--bundle", "evidence/task-1", "--project", "JogoDaCopa",
                "--task-id", "task-1", "--source-sha", "a" * 40, "--file", unsafe,
            ]
            result = subprocess.run(command, text=True, capture_output=True, check=False)
            self.assertEqual(2, result.returncode)


@unittest.skipUnless(POWERSHELL, "Windows PowerShell is required")
class PowerShellSafetyToolTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        git(self.root, "init", "-q")
        git(self.root, "config", "user.email", "tests@estudio.local")
        git(self.root, "config", "user.name", "Estudio Tests")
        (self.root / ".gitattributes").write_text("* text=auto eol=lf\n", encoding="utf-8")
        (self.root / "safe.txt").write_text("safe fixture\n", encoding="utf-8")
        git(self.root, "add", ".gitattributes", "safe.txt")
        git(self.root, "commit", "-qm", "fixture")
        git(self.root, "checkout", "-qb", "codex/test")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def powershell(self, script: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(POWERSHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script), *arguments],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_lfs_registration_is_dry_run_then_literal_apply(self) -> None:
        asset = self.root / "assets/new.bin"
        asset.parent.mkdir()
        asset.write_bytes(b"new binary")
        before = (self.root / ".gitattributes").read_bytes()
        dry = self.powershell(LFS_TOOL, "-Root", str(self.root), "-Path", "assets/new.bin")
        self.assertEqual(0, dry.returncode, dry.stderr)
        self.assertEqual(before, (self.root / ".gitattributes").read_bytes())
        self.assertIn("mode=dry-run", dry.stdout)
        applied = self.powershell(LFS_TOOL, "-Root", str(self.root), "-Path", "assets/new.bin", "-Apply")
        self.assertEqual(0, applied.returncode, applied.stderr)
        attributes = (self.root / ".gitattributes").read_text(encoding="utf-8")
        self.assertIn("assets/new.bin filter=lfs diff=lfs merge=lfs -text", attributes)
        self.assertEqual("", git(self.root, "diff", "--cached", "--name-only").stdout)
        self.assertIn("?? assets/", git(self.root, "status", "--short").stdout)

    def test_lfs_registration_rejects_glob_without_mutation(self) -> None:
        before = (self.root / ".gitattributes").read_bytes()
        result = self.powershell(LFS_TOOL, "-Root", str(self.root), "-Path", "assets/*.bin")
        self.assertNotEqual(0, result.returncode)
        self.assertEqual(before, (self.root / ".gitattributes").read_bytes())

    def test_secret_scan_is_read_only_and_redacts_values(self) -> None:
        clean = self.powershell(SECRET_TOOL, "-Root", str(self.root), "-Path", "safe.txt")
        self.assertEqual(0, clean.returncode, clean.stderr)
        secret = "sk-proj-" + ("A" * 32)
        secret_path = self.root / "secret.txt"
        secret_path.write_text("token=" + secret + "\n", encoding="utf-8")
        before = secret_path.read_bytes()
        found = self.powershell(SECRET_TOOL, "-Root", str(self.root), "-Path", "secret.txt")
        self.assertEqual(1, found.returncode, found.stderr)
        self.assertIn("rule=openai_key", found.stdout)
        self.assertNotIn(secret, found.stdout + found.stderr)
        self.assertEqual(before, secret_path.read_bytes())

    def test_secret_scan_rejects_glob_paths(self) -> None:
        result = self.powershell(SECRET_TOOL, "-Root", str(self.root), "-Path", "*.txt")
        self.assertNotEqual(0, result.returncode)


if __name__ == "__main__":
    unittest.main()
