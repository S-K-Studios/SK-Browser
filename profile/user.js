// SK-Browser user.js — only what policies.json and Firefox defaults don't already cover.
// Deliberately NOT set (they break Gmail/banking sign-in): resistFingerprinting,
// blocking all third-party cookies, forcing DoH. Never disable sandbox, Safe Browsing or updates.
// Validate with: python scripts/check_config.py

// HTTPS-only: warn before loading any plain-HTTP page.
user_pref("dom.security.https_only_mode", true);

// Strip tracking parameters (fbclid, gclid, ...) from URLs.
user_pref("privacy.query_stripping.enabled", true);

// Built-in fingerprinting protection in normal windows (low breakage, unlike resistFingerprinting).
user_pref("privacy.fingerprintingProtection", true);

// Tell sites not to sell/share data (Global Privacy Control).
user_pref("privacy.globalprivacycontrol.enabled", true);

// Send only the origin (not the full URL) to other sites.
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

// Don't expose local IP addresses via WebRTC.
user_pref("media.peerconnection.ice.default_address_only", true);

// No speculative connections to sites you haven't opened.
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);

// ---- Phase 2: UI (vertical tabs, minimal toolbar, dark theme) ----
// Sidebar + vertical tabs (Firefox 136+; verify at about:config on your version).
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
// Required for profile/chrome/userChrome.css to load.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Dark browser UI and dark preference for pages (0 = dark).
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.theme.content-theme", 0);
