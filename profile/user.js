// SK-Browser user.js — Phase 1 hardening for stock Firefox.
// Every pref explains WHY. Do not disable: sandbox, Safe Browsing, auto-updates.
// Validate with: python3 scripts/check_config.py

// ---- Telemetry & studies: stop data leaving the browser ----
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

// ---- Sponsored content, Pocket, suggestions ----
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);

// ---- Tracking protection ----
// 5 = Total Cookie Protection: cookies isolated per top-level site.
user_pref("network.cookie.cookieBehavior", 5);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
// Strip known tracking parameters from URLs.
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
// Global Privacy Control signal (legally meaningful in some jurisdictions).
user_pref("privacy.globalprivacycontrol.enabled", true);
// Built-in, low-breakage fingerprinting protection (preferred over resistFingerprinting,
// which breaks many sites and shifts timezone to UTC; revisit if needed).
user_pref("privacy.fingerprintingProtection", true);

// ---- Referrers: send only the origin cross-site ----
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

// ---- Transport security ----
user_pref("dom.security.https_only_mode", true);

// ---- Network leak reduction ----
// Don't expose local IP addresses via WebRTC.
user_pref("media.peerconnection.ice.default_address_only", true);
// No speculative connections to sites you haven't visited.
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("browser.send_pings", false);

// ---- Credentials (assumption A3: external password manager) ----
user_pref("signon.rememberSignons", false);
