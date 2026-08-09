# MekOps Labs — Home Assistant Add-ons

This repository is a custom Home Assistant add-on repository hosting two add-ons:

| Add-on | Slug | Description |
|--------|------|-------------|
| **Siphon** | `siphon` | High-performance, modular IoT data aggregator, parser, and dispatcher (ETL engine) written in Go. |
| **Deputy** | `deputy` | WANTED control plane — manage Sheriff edge devices, with HA MQTT Discovery. |

For add-on-specific details, see the README in each add-on's directory:
- [`siphon/README.md`](siphon/README.md)
- [`deputy/README.md`](deputy/README.md)

## Releasing

Each add-on versions independently: the Supervisor reads `version:` from its
`config.yaml`, and a release is tagged here as `<slug>-v<version>` — `deputy-v0.3.0`,
`siphon-v0.5.4-1`. The slug prefix is what keeps two add-ons' releases apart in
one repository, and the tag is on the commit that raised `version:`.

An add-on's version tracks the upstream project it packages, so `deputy-v0.3.0`
carries Deputy `v0.3.0`. The upstream tag lives in the upstream repository; this
one marks the packaging.

---

## 🚀 Installation

To install either add-on, add this custom repository to your Home Assistant instance:

1. Navigate to your Home Assistant dashboard.
2. Go to **Settings** > **Add-ons** > **Add-on Store**.
3. Click the three dots (`...`) in the top right corner and select **Repositories**.
4. Paste the URL of this repository: `https://github.com/mekops-labs/ha-addons`
5. Click **Add** and close the dialog.
6. Refresh the page (or wait a moment). Scroll down to the bottom or search for **Siphon ETL** or **Deputy**.
7. Click the Add-on, click **Install**, and once finished, toggle on **Show in sidebar**.
8. Start the Add-on!