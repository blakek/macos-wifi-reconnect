# macos-wifi-reconnect

> 📶 Reconnects to a Wi-Fi network if the connection is lost.

This is a simple script that runs in the background and checks if the Wi-Fi connection has a network connection. If not, it just turns Wi-Fi off and on again to reconnect.

I wrote this because I'm using an older MacBook Air as a server. When the router is restarted, Wi-Fi is not automatically reconnected for some reason. I tried fixing using macOS' built-in Wi-Fi settings, but it didn't work.

If you have a newer system (maybe macOS 11+?), there's an [earlier implementation of this script](https://github.com/blakek/macos-wifi-reconnect/tree/4dbecd4141df7e76673fde0b8616368d2d5c1858) that uses `airportd` instead of `networksetup`. It can connect to a specific network without needing the network password (if you've connected to it before).

## Install

**Installing from source:**

1. Either [clone this repository](https://help.github.com/articles/cloning-a-repository/) or [download the ZIP file](https://github.com/blakek/macos-wifi-reconnect/archive/main.zip)
2. Build from the Makefile:

> **Note:**
> You'll see these running make as root. This is because powering on/off Wi-Fi from the terminal requires root privileges for some reason :shrug:

```bash
sudo make install
```

3. Reboot _or_ load the LaunchAgent using Make:

```bash
sudo make load
```

## License

MIT
