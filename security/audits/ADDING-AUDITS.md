# Adding audit reports

This guide describes how to publish a new audit on the [Audits](README.md) page. It is intended for maintainers only; the page itself stays a simple index for readers.

## Before you add an entry

* Confirm the report is **approved for public disclosure** (not under NDA or internal-only).
* Confirm the audited codebase is **open source** and traceable to a public repository, tag, commit, or release.
* Confirm it covers **Neo X–related** software (contracts, node, bridge, governance, Anti-MEV, and similar).
* Use the **final published report** (not a preliminary draft), unless you intentionally label a draft in the title.

## Where files go

| Item | Location |
| --- | --- |
| PDF files | `security/audits/reports/` |
| Public index | `security/audits/README.md` |

The Audits page is already listed in [`SUMMARY.md`](../../SUMMARY.md) under **Security**. You do not need to change `SUMMARY.md` when adding a report—only when introducing a new top-level page.

## PDF filename convention

Use lowercase kebab-case:

```text
{auditor}-{short-description}-audit-report.pdf
```

| Segment | Guidance | Examples |
| --- | --- | --- |
| `{auditor}` | Firm or program name, lowercase | `red4sec`, `hacken`, `secure3`, `blocksec` |
| `{short-description}` | Brief scope slug (2–5 words) | `xgas`, `zk-dkg`, `evm-bridge`, `neovm-bridge`, `governance`, `neo-x-core` |
| Suffix | Always `audit-report` | — |
| Extension | Always `.pdf` | — |

**Examples**

* `red4sec-xgas-audit-report.pdf`
* `hacken-zk-dkg-audit-report.pdf`
* `secure3-bridge-evm-contracts-audit-report.pdf`

Avoid version numbers, dates, or internal codenames in filenames unless needed to disambiguate two reports from the same auditor on the same component.

## Update the table in `README.md`

Add one row to the table in [`README.md`](README.md). Keep rows in **reverse chronological order** by **Finalized** date (newest first).

### Column reference

| Column | What to write |
| --- | --- |
| **Title** | Human-readable name: component, audit type, and auditor in parentheses. Link the title to the PDF. Example: `[xGAS — Security Audit (Red4Sec)](reports/red4sec-xgas-audit-report.pdf)` |
| **Scope** | One or two sentences: what was audited, main technologies, and a link to the audited repository (with commit or branch if useful). |
| **Finalized** | Date the report was published (`YYYY-MM-DD`). Prefer the date on the report cover; if the cover only shows an engagement window, use the final report date from the changelog. |
| **Report** | `[PDF](reports/{filename}.pdf)` using the same path as in the title link. |

### Row template

Copy and fill in (place the new row in date order):

```markdown
| [{Title}](reports/{auditor}-{description}-audit-report.pdf) | {Scope description}. Repository: [{repo-name}]({repo-url}). | {YYYY-MM-DD} | [PDF](reports/{auditor}-{description}-audit-report.pdf) |
```

### Example

```markdown
| [xGAS — Security Audit (Red4Sec)](reports/red4sec-xgas-audit-report.pdf) | Wrapped native asset on Neo X: ERC-20 deposit/withdraw, ERC-2612 permits, and EIP-3009 transfer authorizations. Repository: [bane-labs/xgas](https://github.com/bane-labs/xgas). | 2026-05-20 | [PDF](reports/red4sec-xgas-audit-report.pdf) |
```

## Intro text

Do **not** list specific products or components in the opening paragraph of [`README.md`](README.md). That text is intentionally generic so new table rows do not require editing it.

## Removing or withholding a report

If a report must not be public:

1. Remove its row from the table in `README.md`.
2. Delete the PDF from `security/audits/reports/`.
3. Do not reference the report elsewhere in this docs repo.

## Checklist

- [ ] Disclosure approved for publication
- [ ] Audited codebase is open source and traceable to a public repository, tag, commit, or release
- [ ] PDF added under `security/audits/reports/` with correct filename
- [ ] Table row added in `README.md` (newest date first)
- [ ] Title and Report links point to the same PDF path
- [ ] Finalized date matches the published report
- [ ] Intro paragraph in `README.md` left unchanged
