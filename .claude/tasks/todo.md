# Asset Management System — Build Plan

Greenfield Django build. Today only `.claude/` tooling and `AssetManagementSystem.md` (the 0–20 module spec)
exist in the repo. Bootstrap the foundation + Module 0 first, then build Modules 1–20 on demand with `/next-module`.

**Stack:** Django 5.1 (function-based views, `@login_required`), Tailwind (Play CDN) + HTMX + Chart.js + Lucide,
MySQL/MariaDB (XAMPP) via PyMySQL, DB `nav_ams`. **Multi-tenant:** every model has a `tenant` FK; every view filters
`tenant=request.tenant`. Run Python via the venv: `venv\Scripts\python.exe manage.py ...`.

## Phase 0 — Foundation + Module 0 (bootstrap)
- [ ] `config/` project (settings reads `.env`; urls; PyMySQL + MariaDB-10.4 shim in `config/__init__.py`)
- [ ] `apps/core` — Tenant model, TenantMiddleware, navigation (MODULE_CATALOG 0–20 + LIVE_LINKS), AuditLog,
      context processors, `decorators.tenant_admin_required`, `utils.log_action`, roadmap placeholder + audit-log views
- [ ] `apps/accounts` — User (tenant FK, `is_tenant_admin`, role FK), Role, UserInvite; email-or-username backend;
      login/register/forgot+reset/invite-accept; user/role/invite CRUD; profile; change-password
- [ ] `apps/tenants` — **Module 0: Tenant & Subscription Management** (the flagship reference module):
      OnboardingStep, Subscription, Invoice (`INV-#####`), EncryptionKey, BrandingSetting, HealthMetric — full CRUD
- [ ] `apps/dashboard` — aggregation-only landing (KPIs + Chart.js charts; no models)
- [ ] Blue/white responsive dashboard theme (`static/css/theme.css` design system) + `templates/base.html` + sidebar
- [ ] `.env` (MySQL XAMPP) + idempotent `seed_demo` (tenants/roles/users + Module 0 data) + README

## Modules 1–20 (build with /next-module, one at a time, in order)
- [ ] 1  `procurement`     — Asset Procurement & Acquisition
- [ ] 2  `inventory`       — Asset Inventory & Tracking
- [ ] 3  `classification`  — Asset Classification & Categorization
- [ ] 4  `depreciation`    — Depreciation & Financial Management
- [ ] 5  `maintenance`     — Maintenance & Repair Management
- [ ] 6  `performance`     — Asset Performance & Utilization
- [ ] 7  `reliability`     — Asset Reliability & Condition Monitoring
- [ ] 8  `warranty`        — Warranty & Insurance Management
- [ ] 9  `disposal`        — Asset Disposal & Retirement
- [ ] 10 `leasing`         — Lease & Rental Management
- [ ] 11 `compliance`      — Compliance & Regulatory Management
- [ ] 12 `risk`            — Asset Risk Management
- [ ] 13 `mobile`          — Mobile Asset Management
- [ ] 14 `analytics`       — Asset Analytics & Business Intelligence
- [ ] 15 `integrations`    — Integration & API Hub
- [ ] 16 `documents`       — Document & Knowledge Management
- [ ] 17 `facilities`      — Space & Facility Asset Management
- [ ] 18 `itam`            — IT Asset Management (ITAM)
- [ ] 19 `fleet`           — Fleet & Vehicle Management
- [ ] 20 `administration`  — System Administration & Security

## Per-module sequence (CLAUDE.md "Module Creation Sequence")
For each module: write code → `code-reviewer` → `explorer` → `frontend-reviewer` → `performance-reviewer` →
`qa-smoke-tester` → `security-reviewer` → `test-writer`. One file per commit after each step. Never `git push`.

## Quality bar (every module)
Migrates cleanly to `nav_ams`; seeds idempotently; passes `manage.py check`; every list page renders 200 with
working search/filters/pagination + Actions (view/edit/delete); all sub-modules show **Live** in the sidebar;
matches the blue/white Tailwind design system; isolates data per tenant (cross-tenant pk → 404).

## Review (outcome)
_Nothing built yet — fill this in as modules ship._
