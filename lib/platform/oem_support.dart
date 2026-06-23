/// Manufacturers known to aggressively freeze or kill background (even
/// foreground) services. On these, the speed-bump watcher needs the OEM
/// "app launch / protected apps" whitelist to stay alive — a battery
/// optimization exemption alone is not enough (verified on HONOR/MagicOS, where
/// the watcher is frozen within seconds of Cairn going to the background).
const aggressiveOems = {
  'huawei', 'honor', 'xiaomi', 'redmi', 'poco', 'oppo', 'realme',
  'vivo', 'iqoo', 'oneplus', 'meizu', 'samsung', 'tecno', 'infinix',
  'asus', 'lenovo',
};

/// Whether [manufacturer] (Build.MANUFACTURER, any case) is an OEM where Cairn
/// must guide the user to the app-launch whitelist to keep the guard running.
bool isAggressiveOem(String manufacturer) =>
    aggressiveOems.contains(manufacturer.trim().toLowerCase());
