# پروتکل‌های پشتیبانی‌شده

MoaV بیش از ۱۶ پروتکل عبور از فیلترینگ و مسیر جایگزین را راه‌اندازی می‌کند، به همراه امکان اهدای اختیاری پهنای باند به پروژه‌های Psiphon، Tor و MahsaNet. هر یک از این روش‌ها از نظر تکنیک‌های ضدشناسایی (Anti-detection)، سرعت و نیازمندی‌های شبکه‌ای ویژگی‌های متفاوتی دارند. همین تنوع ساختاری باعث می‌شود که در صورت مسدودسازی یک پروتکل، سایر مسیرها همچنان فعال و در دسترس باقی بمانند.

## نمای کلی پروتکل‌ها

<!-- BEGIN gen:overview-table -->
| پروتکل | پورت | پنهان‌کاری | سرعت | نیاز به دامنه |
|----------|------|---------|-------|-----------------|
| [Reality (VLESS)](#reality-vless) | 443/tcp | خیلی بالا | بالا | خیر |
| [Trojan](#trojan) | 8443/tcp | بالا | بالا | بله |
| [AnyTLS](#anytls) | 8445/tcp | خیلی بالا | بالا | بله |
| [Hysteria2](#hysteria2) | 443/udp | بالا | خیلی بالا | بله |
| [Shadowsocks-2022](#shadowsocks-2022) | 8388/tcp+udp | بالا | خیلی بالا | خیر |
| [CDN (VLESS+WS)](#cdn-vlessws) | 443 via CDN | خیلی بالا | متوسط | <span dir="ltr">Cloudflare: بله</span> · <span dir="ltr">CloudFront: خیر</span> |
| [TrustTunnel](#trusttunnel) | 4443/tcp+udp | خیلی بالا | بالا | بله |
| [WireGuard](#wireguard) | 51820/udp | متوسط | خیلی بالا | خیر |
| [AmneziaWG](#amneziawg) | 51821/udp | خیلی بالا | بالا | خیر |
| [WireGuard (wstunnel)](#wireguard-wstunnel) | 8080/tcp | بالا | بالا | خیر |
| [Telegram MTProxy](#telegram-mtproxy) | 993/tcp | بالا | متوسط | خیر |
| [dnstt](#dnstt) | 53/udp | متوسط | پایین | بله |
| [Slipstream](#slipstream) | 53/udp | متوسط | پایین تا متوسط | بله |
| [MasterDNS](#masterdns) | 53/udp | متوسط | متوسط | بله |
| [GooseRelay](#gooserelay) | 8444/tcp | خیلی بالا | پایین تا متوسط | خیر |
| [Psiphon Conduit](#psiphon-conduit) | dynamic | بالا | متوسط | خیر |
| [XHTTP (VLESS+XHTTP+Reality)](#xhttp-vlessxhttpreality) | 2096/tcp | خیلی بالا | بالا | خیر |
| [XDNS (VLESS+mKCP+DNS)](#xdns-vlessmkcpdns) | 53/udp | متوسط | پایین | بله |
| [Tor Snowflake](#tor-snowflake) | dynamic | بالا | پایین | خیر |
| [MahsaNet](#mahsanet) | — | — | — | خیر |
<!-- END gen:overview-table -->

## جزئیات پروتکل‌ها

### Reality (VLESS)

**پروتکل اصلی:** ترکیب VLESS به همراه Reality باعث می‌شود ترافیک پروکسی شما دقیقاً شبیه به یک اتصال TLS واقعی به یک وب‌سایت معتبر (مانند `dl.google.com`) به نظر برسد. در این روش، سرور گواهی TLS واقعی همان سایت هدف را ارائه می‌دهد و حتی در برابر بررسی و کاوش فعال (Active Probing) نیز عملکرد موفقی دارد.

- **پورت:** `443/tcp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box)
- **کلاینت‌ها:** Streisand, Hiddify, v2rayNG, v2rayN, NekoBox

### Trojan

پروکسی TLS با رمز عبور. ترافیک آن دقیقاً شبیه به HTTPS معمولی به نظر می‌رسد و از گواهی TLS واقعی دامنه شما (که توسط Let's Encrypt صادر شده) استفاده می‌کند.

- **پورت:** `8443/tcp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box)
- **کلاینت‌ها:** Streisand, Hiddify, v2rayNG, v2rayN, Shadowrocket

### AnyTLS

پروکسی TLS با رمز عبور برای مقاومت در برابر ردپای (Fingerprint) **TLS-in-TLS** طراحی شده است. این پروتکل با تغییر اندازه رکوردها و اعمال پدینگ (Padding)، الگوی TLS-در-TLS را که سیستم‌های DPI برای شناسایی پروکسی‌های تونل‌شده روی TLS به کار می‌برند خنثی کرده و پنهان‌کاری (Stealth) بالایی در برابر این روش‌های فیلترینگ ارائه می‌دهد. این ابزار از همان موتور sing-box، گواهی TLS مربوط به Trojan و دامنه سرور شما استفاده می‌کند.

- **پورت:** `8445/tcp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box) (1.13.x)
- **کلاینت‌ها:** Hiddify, sing-box (SFA/SFI), NekoBox/NekoRay, Mihomo Party, Shadowrocket 2.2.65+
- **نکته:** اختیاری است — با `ENABLE_ANYTLS=true` روشن می‌شود. دامنه (TLS) لازم است. پشتیبانی کلاینت از VLESS/Trojan محدودتر است؛ کلاینت‌های قدیمی یا <span dir="ltr">(v2rayNG, Streisand, V2Box, Clash Verge) Clash-only</span> از AnyTLS **پشتیبانی نمی‌کنند**.

### Hysteria2

پروتکل مبتنی بر QUIC برای دستیابی به کارایی و توان عملیاتی بالا در شبکه‌های ناپایدار بهینه‌سازی شده است. این پروتکل از قابلیت داخلی مبهم‌سازی ترافیک (Obfuscation) استفاده می‌کند تا از شناسایی و مسدودسازی ترافیک QUIC توسط سیستم‌های فیلترینگ جلوگیری کند.


- **پورت:** `443/udp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box)
- **کلاینت‌ها:** Streisand, Hiddify, v2rayNG, v2rayN
- **نکته:** به UDP نیاز دارد. در برخی شبکه‌های دارای فیلترینگ که UDP غیرمرتبط با <span dir="ltr"> (non-DNS UDP) DNS </span> را به‌طور کامل مسدود می‌کنند، قابل استفاده نیست.

**کنترل ازدحام (Congestion Control):** پارامترهای `up_mbps` / `down_mbps` تنظیم نشده‌اند و مقدار `ignore_client_bandwidth: true` فعال است تا هر دو طرف روی BBR باقی بمانند و پهنای باند اعلام‌شده از سوی کلاینت باعث سوئیچ الگوریتم لینک به Brutal نشود (اتفاقی که می‌تواند یک VPS با رم پایین را اشباع کند). این BBR مربوط به لایهٔ QUIC در خود Hysteria2 داخل sing-box است — هیچ ارتباطی با ماژول کرنل `tcp_bbr` ندارد و به سیستم‌عامل میزبان وابسته نیست.

### Shadowsocks-2022

AEAD-2022 Shadowsocks (`2022-blake3-aes-128-gcm`), نسل مدرن Shadowsocks با کلیدهای مجزا برای هر کاربر و مقاومت داخلی در برابر کاوش فعال (Active Probing) و حملات بازپخش یا تکرار (Replay Attacks). این پروتکل **نیازی به دامنه و گواهی TLS ندارد**؛ بنابراین در حالت بدون دامنه به‌خوبی کار می‌کند و زمانی که استفاده از پروتکل‌های مبتنی بر گواهی ممکن یا مناسب نیست، جایگزین بسیار خوبی است. همچنین از نظر پروتکل، سازگاری کاملی با اپلیکیشن Outline دارد.



- **پورت:** `8388/tcp` + `8388/udp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box)
- **کلاینت‌ها:** Outline (iOS/Android/desktop), NekoBox/NekoRay, Hiddify, Streisand, sing-box — با URI استاندارد `ss://`
- **نکته:** به‌صورت پیش‌فرض فعال است (`ENABLE_SS=true`). اگر پورت 8388 توسط ISP شما از طریق شناسایی الگوی ترافیک (Fingerprinting) شناسایی شود، مقدار `PORT_SS` را در فایل <span dir="ltr">`.env` </span> به پورتی کمتر قابل شناسایی تغییر دهید و سپس دستور `moav restart sing-box` را اجرا کنید.


### CDN (VLESS+WS)

ترافیک VLESS را از مسیر CDN کلادفلر، روی WebSocket، عبور می‌دهد. وقتی IP سرور مسدود باشد، ترافیک از Cloudflare عبور می کند؛ مسدودسازی بر اساس IP خیلی سخت‌تر می‌شود، چون کلاینت‌ها از زیرساخت CDN وصل می‌شوند.

**اختیاری:** مقدار پیش‌فرض `ENABLE_CDN=false` است، زیرا این لینک تنها زمانی کار می‌کند که زیردامنه (Subdomain) از طریق CDN پروکسی شده و به پورت CDN بازنویسی شده باشد. پس از راه‌اندازی [حالت CDN](DNS.md#cdn-mode)، این گزینه را فعال کنید.


- **پورت:** `443 (Cloudflare)` → `2082` (origin)
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box)
- **کلاینت‌ها:** Streisand, Hiddify, v2rayNG, v2rayN
- **نیازمندی:** یک دامنه پروکسی‌شده توسط Cloudflare (<span dir="ltr">Cloudflare-proxied</span>) که کنترل آن در اختیار شما باشد؛ AWS CloudFront می‌تواند از نام میزبان توزیع (Distribution Hostname) استفاده کند و نیازی به دامنه اختصاصی ندارد.

### TrustTunnel

پروتکل VPN مدرن که شبیه ترافیک HTTPS معمولی است. هم HTTP/2 (TCP) را پشتیبانی می‌کند هم HTTP/3 (QUIC/UDP).

- **پورت:** `4443/tcp` + `4443/udp`
- **موتور:** [TrustTunnel](https://github.com/TrustTunnel/TrustTunnel) (سرور) / [TrustTunnelClient](https://github.com/TrustTunnel/TrustTunnelClient) (کلاینت)
- **کلاینت‌ها:** اپ TrustTunnel (<span dir="ltr">iOS, Android, macOS, Windows, Linux</span>)

### WireGuard

VPN سریع در سطح کرنل. ساده، ارزیابی‌شده از نظر امنیتی و با پشتیبانی گسترده. این پروتکل از اتصال مستقیم UDP استفاده می‌کند.

- **پورت:** `51820/udp`
- **موتور:** [sing-box](https://github.com/SagerNet/sing-box) + [wstunnel](https://github.com/erebe/wstunnel)
- **کلاینت‌ها:** اپ WireGuard (همهٔ پلتفرم‌ها)
- **نکته:** به راحتی بوسیله DPI قابل تشخیص است. در شبکه‌های فیلترشده از AmneziaWG یا نسخهٔ wstunnel استفاده کنید.

### AmneziaWG

WireGuard مبهم‌شده (Obfuscated WireGuard) که برای مقابله با الگوهای رایج شناسایی توسط DPI طراحی شده است. با افزودن بسته‌های زائد، تغییر زمان‌بندی Handshake و دستکاری فیلدهای Header، از شناسایی جلوگیری می‌کند.


- **پورت:** `51821/udp`
- **موتور:** [amneziawg-tools](https://github.com/amnezia-vpn/amneziawg-tools)
- **کلاینت‌ها:** AmneziaVPN (<span dir="ltr">iOS, Android, macOS, Windows, Linux</span>)

### WireGuard (wstunnel)

* **WireGuard از طریق WebSocket (TCP) تونل می‌شود:** در صورت مسدودسازی کامل UDP قابل استفاده است. اگر `DOMAIN` تنظیم شده باشد، تونل از طریق **`wss://` (TLS)** و با گواهی Let's Encrypt سرور برقرار می‌شود تا فرآیند ارتقای WebSocket (WebSocket Upgrade) مشابه یک اتصال معمولی HTTPS به نظر برسد. در حالت بدون دامنه، فقط از **`ws://`**  استفاده می‌شود. همچنین برای هر نصب، یک **رمز عبور اختصاصی مسیر ارتقای HTTP** الزامی است تا اسکنرها بدون داشتن آن نتوانند فرآیند ارتقای WebSocket را تکمیل کنند. دستور دقیق اتصال کلاینت — شامل طرح صحیح **`wss://`/`ws://**` و پیشوند مسیر — در فایل `wireguard-instructions.txt` هر بسته کاربر قرار دارد.

- **پورت:** `8080/tcp`
- **موتور:** [wstunnel](https://github.com/erebe/wstunnel) دور کانتینر WireGuard
- **کلاینت‌ها:** اپ WireGuard + باینری wstunnel
- **نکته:** پس از ارتقای یک نصب موجود، ایمیج را مجدداً Build کنید (`moav build wstunnel`) و فرآیند Bootstrap را دوباره اجرا کنید تا **Secret path** تولید شده و `wss://` فعال شود؛ Bundleهای قدیمی تا زمانی که مجدداً صادر نشوند، همچنان از طریق `ws://` کار می‌کنند.


### Telegram MTProxy

پروکسی مخصوص تلگرام با Fake-TLS V2. اتصال TLS واقعی را شبیه‌سازی می‌کند، از جمله تقلید گواهی و شبیه‌سازی زمان‌بندی. وقتی تلگرام بسته است، دسترسی مستقیم می‌دهد.

- **پورت:** `993/tcp` (پورت IMAPS برای پنهان‌کاری)
- **موتور:** [telemt](https://github.com/telemt/telemt)
- **کلاینت‌ها:** اپ تلگرام (تنظیمات پروکسی داخلی)

??? note "تنظیمات ضد DPI"

    telemt بیش از ۱۷ تنظیم قابل‌پیکربندی برای شبکه‌های خصمانه دارد. همه در `.env` قابل تنظیم‌اند:

    **استتار ترافیک (ضد DPI):**

    | تنظیم | پیش‌فرض | کاربرد |
    |---------|---------|---------|
    | `TELEMT_KEEPALIVE_RANDOM` | `true` | تصادفی‌کردن payload keepalive تا تطبیق الگوی DPI بشکند |
    | `TELEMT_KEEPALIVE_JITTER` | `4` | تصادفی‌سازی زمان‌بندی Keepalive به میزان ±N ثانیه|
    | `TELEMT_KEEPALIVE_INTERVAL` | `20` | فاصلهٔ پایهٔ keepalive به ثانیه |
    | `TELEMT_WARMUP_JITTER` | `200` | تصادفی‌کردن زمان برقراری اتصال (میلی‌ثانیه) |

    **تاب‌آوری استخر اتصال:**

    | تنظیم | پیش‌فرض | کاربرد |
    |---------|---------|---------|
    | `TELEMT_POOL_SIZE` | `12` | تعداد اتصال‌های پایدار به DCهای تلگرام |
    | `TELEMT_REINIT_SECS` | `600` |(از شناسایی الگوی اتصال‌های طولانی جلوگیری می‌کند) |
    | `TELEMT_HARDSWAP` | `true` | ساخت استخر جدید قبل از خراب کردن استخر قدیمی (چرخش بدون قطعی) |
    | `TELEMT_HARDSWAP_DELAY_MIN` | `500` | کمینهٔ تأخیر بین اتصال‌های جدید هنگام تعویض (میلی‌ثانیه) |
    | `TELEMT_HARDSWAP_DELAY_MAX` | `1200` | بیشینهٔ تأخیر بین اتصال‌های جدید هنگام تعویض (میلی‌ثانیه) |

    **وصل‌شدن سریع دوباره:**

    | تنظیم | پیش‌فرض | کاربرد |
    |---------|---------|---------|
    | `TELEMT_FAST_RETRIES` | `10` | تلاش های مجدد سریع پیش از backoff نمایی |
    | `TELEMT_BACKOFF_BASE` | `300` | فاصلهٔ زمانی backoff اولیه (میلی‌ثانیه) |
    | `TELEMT_BACKOFF_CAP` | `10000` | حداکثر فاصله زمانی Backoff (میلی‌ثانیه)|

    **پایداری تنظیمات:**

    | تنظیم | پیش‌فرض | کاربرد |
    |---------|---------|---------|
    | `TELEMT_STABLE_SNAPSHOTS` | `3` |  N اسنپشات پیاپی و یکسان پیش از اعمال تغییرات لازم است |
    | `TELEMT_APPLY_COOLDOWN` | `120` | حداقل فاصله زمانی بین تغییرات تنظیمات |

    **برای فیلترینگ شدید** (مثلاً ایران هنگام قطعی): `TELEMT_POOL_SIZE` را به ۱۶ تا ۲۰ برسانید، `TELEMT_REINIT_SECS` را به ۳۰۰ کم کنید، و `TELEMT_FAST_RETRIES` را به ۲۰ بالا ببرید.

    مستندات کامل تنظیم: [telemt TUNING.en.md](https://github.com/telemt/telemt/blob/main/docs/TUNING.en.md) | [مستندات API](https://github.com/telemt/telemt/blob/main/docs/API.md)


### GooseRelay

تونل SOCKS5 از طریق یک وب اپلیکیشن **Google Apps Script** که کاربر آن را در حساب گوگل خودش Deploy می‌کند و درخواست‌ها را به سرور خروجی VPS ارسال می‌کند. در سطح شبکه، کلاینت فقط در ظاهر یک درخواست HTTPS به `google.com` ارسال می‌کند؛ Payload به‌صورت **AES-256-GCM** و به‌صورت End-to-End بین Endpointهای GooseRelay رمزنگاری می‌شود، بنابراین Apps Script فقط Ciphertext را Relay می‌کند، هرچند گوگل همچنان می‌تواند Metadata مربوط به درخواست را مشاهده کند. این همان کامپوننت **GooseRelay** است که در MahsaNG v16 قرار دارد. **بسیار مخفی‌کارانه است** و شبیه ترافیک گوگل به نظر می‌رسد، اما توان عملیاتی به دلیل محدودیت حدود **۲۰ هزار فراخوانی در روز برای هر حساب** در Apps Script محدود می‌شود.

- **پورت:** `${PORT_GOOSE}`/`tcp` (به‌صورت پیش‌فرض 8444 روی Host → 8443 در Container؛ پورت 8443 روی Host متعلق به Trojan است)
- **موتور:** [GooseRelayVPN](https://github.com/kianmhz/GooseRelayVPN) (Go)، سرور ساخته‌شده از Source
- **کلاینت‌ها:** MahsaNG v16+ یا کلاینت مستقل GooseRelay به‌همراه یک Forwarder مبتنی بر Apps Script که توسط کاربر Deploy شده باشد
- **رمزنگاری:** AES-256-GCM، با `tunnel_key` مشترک 64-hex (در فایل `gooserelay-instructions.txt` هر کاربر)
- **نیازمندی:** به دامنه نیاز ندارد. `PORT_GOOSE` باید از شبکه Google قابل دسترسی باشد. کاربر باید `RELAY_URLS = ['http://SERVER_IP:PORT_GOOSE/tunnel']` را در Apps Script خود تنظیم کند.
- **نکته:** به‌صورت اختیاری فعال می‌شود. برای فعال‌کردن آن، `ENABLE_GOOSERELAY=true` را در <span dir="ltr"> `.env` </span> قرار دهید. ترافیک خروجی از طریق sing-box مسیریابی می‌شود. اپلیکیشن‌های Real-time مانند Telegram/X سهمیه Apps Script را سریع مصرف می‌کنند؛ برای افزایش ظرفیت، Deploymentهای بیشتری را تحت حساب‌های مختلف Google ایجاد کنید.

### XHTTP (VLESS+XHTTP+Reality)

**آزمایشی:** VLESS روی لایه انتقال (Transport) XHTTP با استتار TLS مبتنی بر Reality (ارائه‌شده توسط Xray-core). این پروتکل از لایه انتقال (Transport) XHTTP (که قبلاً `splithttp` نام داشت) برای ارسال چندگانه (Multiplexed) درخواست‌های HTTP استفاده می‌کند تا ترافیک مشابه وب‌گردی عادی به نظر برسد. همچنین Reality امکان استفاده از TLS را بدون نیاز به دامنه اختصاصی فراهم می‌سازد.

- **پورت:** `2096/tcp`
- **موتور:** [Xray-core](https://github.com/XTLS/Xray-core)
- **کلاینت‌ها:** V2rayNG، Hiddify، Streisand، V2Box، V2rayN، V2rayU، NekoBox
- **نکته:** از Xray-core استفاده می‌کند که از sing-box جداست. با قرار دادن `ENABLE_XHTTP=false` در <span dir="ltr"> `.env` </span> آن را غیرفعال کنید.

### Psiphon Conduit

اهدای پهنای باند به شبکه Psiphon. کاربران Psiphon در سراسر جهان از طریق سرور شما مسیریابی می‌شوند. این یک پروتکل برای اتصال شما نیست، بلکه روشی برای کمک به دیگران جهت عبور از فیلترینگ است.

- **موتور:** [Psiphon Conduit](https://github.com/Psiphon-Inc/conduit)
- **کلاینت‌ها:** اپلیکیشن [Psiphon](https://psiphon.ca/) برای iOS، Android و Windows

#### Conduit شما چگونه به کاربران ایران کمک می‌کند

دو روش وجود دارد که Conduit در حال اجرای شما به کاربران دسترسی پیدا می‌کند:

1. **استخر عمومی(Public Pool) — خودکار، نیازی به اشتراک‌گذاری نیست.** به محض اجرای Conduit،
   پهنای باند را به شبکه Psiphon اهدا می‌کند. کاربران اپلیکیشن Psiphon —
   از جمله در ایران — به‌صورت خودکار از طریق سرور شما مسیریابی می‌شوند. آن‌ها
   به لینک، دعوت‌نامه یا هیچ تنظیماتی نیاز ندارند. این روش اصلی کمک Conduit است
   و هیچ اقدامی از سمت کاربر لازم ندارد.

2. **جفت‌سازی شخصی(Personal Pairing) — اشتراک‌گذاری یک مسیر خصوصی با افراد خاص.** Conduit مربوط به
   Psiphon به شما امکان می‌دهد به دوستان/خانواده یک مسیر خصوصی و اولویت‌دار از طریق
   ایستگاه خود بدهید. اپلیکیشن Psiphon برای این کار یک فیلد «pairing URL» دارد.
   برای راه‌اندازی: اپلیکیشن **Ryve** مربوط به Psiphon (مدیر Conduit) را نصب کنید،
   ایستگاه خود را با لینک claim که MoaV تولید می‌کند وارد کنید، سپس در Ryve گزینه
   Personal Pairing را فعال کرده و یک لینک جفت‌سازی تولید کنید تا برای افراد در ایران ارسال شود.

#### `moav conduit link`

```bash
moav conduit link      # Claim link + QR + راهنمای مرحله‌به‌مرحله اشتراک‌گذاری
moav conduit status    # وضعیت اجرا + کلاینت‌های متصل / پهنای باند
```

این دستور **Ryve claim deep link** (`network.ryve.app://…claim=…`) و کد QR آن را به‌همراه راهنمای اشتراک‌گذاری بالا نمایش می‌دهد.

> **⚠ نکته امنیتی:** لینک یا کد QR مربوط به claim، حاوی کلید خصوصی این Conduit است؛ بنابراین این لینک صرفاً برای افزودن (import) ایستگاه به اپلیکیشن Ryve روی دستگاه شخصی خودتان استفاده می‌شود. با این لینک مانند یک رمز عبور رفتار کرده و از انتشار عمومی آن جداً خودداری کنید (زیرا هر کسی به آن دسترسی داشته باشد، کنترل ایستگاه شما را به‌دست خواهد گرفت). لینکی که باید به‌صورت عمومی و امن در اختیار بقیه بگذارید، همان لینک «Personal Pairing» است که داخل Ryve تولید می‌شود، نه لینک claim.
> طبق تغییرات ثبت‌شده در [Psiphon-Inc/conduit#205](https://github.com/Psiphon-Inc/conduit/issues/205)، خروجی گرفتن (Export) از pairing-URL تنها از طریق رابط کاربری اپلیکیشن Conduit/Ryve امکان‌پذیر است؛ به‌همین دلیل MoaV صرفاً لینک claim و مراحل کار را به شما نشان می‌دهد و خودش به‌صورت مستقیم pairing URL تولید نمی‌کند. (همچنین دستور `moav donate info` به‌عنوان یک نام مستعار برای `moav conduit link` عمل می‌کند.)

### Tor Snowflake

اهدای پهنای باند به شبکه مانند Conduit، هدف این قابلیت کمک به دیگران است؛ به این صورت که به‌عنوان یک Snowflake Proxy عمل کرده و به کاربران Tor در مناطق تحت فیلترینگ کمک می‌کند تا به اینترنت آزاد متصل شوند.

- **موتور:** [Snowflake](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake)
- **کلاینت‌ها:** [Tor Browser](https://www.torproject.org/) با Snowflake Bridge

### MahsaNet

اهدای کانفیگ به [MahsaServer.com](https://www.mahsaserver.com/), پلتفرمی غیرمتمرکز برای اشتراک‌گذاری کانفیگ‌های VPN جهت استفاده در اپلیکیشن [Mahsa VPN](https://www.mahsaserver.com/). با بیش از ۲ میلیون کاربر در ایران، Mahsa VPN به کانفیگ‌های اهدایی از سرورهای سراسر جهان متصل می‌شود. برخلاف Conduit و Snowflake که پهنای باند را اهدا می‌کنند، MahsaNet لینک‌های کانفیگ VPN سرور شما را اهدا می‌کند تا کاربران Mahsa VPN مستقیماً به سرور شما متصل شوند.

- **پروتکل‌های پشتیبانی‌شده:** Reality (VLESS)، Hysteria2، Trojan، CDN (VLESS+WS)
- **کلاینت‌ها:** اپلیکیشن [Mahsa VPN](https://www.mahsaserver.com/) برای Android و iOS
- **راه‌اندازی:** در MahsaServer.com ثبت‌نام کنید، API Key دریافت کنید، سپس دستور `moav donate` را اجرا کنید
- **داشبورد:** اهدا، مشاهده و مدیریت کانفیگ‌ها از طریق Admin Dashboard.

## DNS Tunnels

وقتی یک شبکه تقریباً تمامی پروتکل‌ها را مسدود یا محدود می‌کند، پروتکل DNS معمولاً همچنان برای Resolve کردن دامنه‌ها فعال است؛ زیرا مسدودسازی کامل آن می‌تواند عملکرد بخش بزرگی از اینترنت را مختل کند. تونل‌های DNS ترافیک را در قالب Queryهای DNS کدگذاری می‌کنند و بنابراین زمانی که تمام ترافیک عادی مسدود شده باشد، اما سامانه نام‌گشا (DNS Resolver) همچنان پاسخ دهد، می‌توانند قابل استفاده باقی بمانند.

این روش **بسیار کند** است. آن را صرفاً به‌عنوان یک گزینه اضطراری برای زنده نگه‌داشتن ابزارهای پیام‌رسان و Chat در نظر بگیرید، نه یک پروتکل ارتباطی برای استفاده روزمره.

### نحوه کار

MoaV چهار تونل DNS را **به‌صورت هم‌زمان** روی همان پورت عمومی ۵۳ اجرا می‌کند. یک سرویس سبک به زبان Go با نام `dns-router` تنها سرویسی است که روی این پورت Bind می‌شود؛ این سرویس پیشوند (Prefix) مربوط به زیردامنه (Subdomain) هر Query را بررسی کرده و آن را به کانتینر تونل مربوطه روی یک پورت داخلی ارسال (Forward) می‌کند.

```text
              Public 53/udp
                   │
            ┌──────▼──────┐
            │ dns-router  │   ← روی پورت 53 listener تنها
            └──────┬──────┘
                   │   (Subdomain Prefix)مسیریابی بر اساس پیشوند زیردامنه
       t.*  ─────►  dnstt        (KCP + Noise)
       s.*  ─────►  slipstream   (QUIC-over-DNS)
       m.*  ─────►  masterdns    (ARQ, MahsaNG-native)
       x.*  ─────►  xray         (XDNS via FinalMask)
                   │
                   ▼
              sing-box  ──►  internet
```

از آنجا که این تونل‌ها به‌جای پورت بر اساس زیردامنه (Subdomain) از یکدیگر تفکیک می‌شوند، نیازی به انتخاب یکی از آن‌ها نیست. کاربر می‌تواند با هر تونلی که کلاینتش پشتیبانی می‌کند متصل شود و هر چهار تونل قادرند به‌صورت هم‌زمان ترافیک را سرویس ‌دهی کنند.

### چیزی که MoaV برای شما تنظیم می‌کند

هر تونل به یک **واگذاری دامنه (NS Delegation)** نیاز دارد که زیردامنه (Subdomain) آن را به سرور شما ارجاع دهد، به همراه یک **A Record** برای خودِ **Nameserver**:

```
dns.yourdomain.com  A   YOUR_SERVER_IP     # Nameserver
t.yourdomain.com    NS  dns.yourdomain.com # dnstt
s.yourdomain.com    NS  dns.yourdomain.com # Slipstream
m.yourdomain.com    NS  dns.yourdomain.com # MasterDNS
x.yourdomain.com    NS  dns.yourdomain.com # XDNS
```

دستور `moav doctor dns` رکورد‌های موردنیاز پیکربندی (Configuration) شما را دقیقاً در فایل `outputs/dns-records.txt` می‌نویسد تا برای  وارد کردن (Import) به Cloudflare آماده باشند. راهنمای کامل: [DNS Configuration](https://www.google.com/search?q=DNS.md%23with-a-domain-the-records).

هر چهار تونل به‌صورت پیش‌فرض فعال هستند. می‌توانید آن‌ها را به‌صورت جداگانه با `ENABLE_DNSTT` / `ENABLE_SLIPSTREAM` / `ENABLE_MASTERDNS` / `ENABLE_XDNS` فعال یا غیرفعال کنید، یا ترکیب موردنظر را با یک دستور تنظیم کنید:

```bash
moav switch-dns                                    # نمایش وضعیت فعلی
moav switch-dns dnstt+slipstream+masterdns+xdns    # هر چهار مورد
moav switch-dns dnstt+slipstream                   # جفت کلاسیک
moav switch-dns off                                # بدون تونل DNS
```

اگر یک کانتینر (Container) مربوط به یک تونل غیرفعال باشد، خاموش می‌ماند و سرویس `dns-router` نیز پورت پشتیبانی (Backend) برای **ارسال (Forward)** ترافیک به آن نخواهد داشت. همچنین پورت **53/udp** باید بدون مانع به سرور برسد؛ توجه داشته باشید که برخی از ارائه‌دهندگان خدمات اینترنتی (ISP) این پورت را روی خطوط خانگی (Residential) به‌طور کامل مسدود می‌کنند.

### کدام‌یک را باید استفاده کنم؟

| تونل           | Subdomain | سرعت نسبت به dnstt  | مقاومت در برابر افت بسته                     | بهترین کاربرد                                                         |
| -------------- | --------- | ------------------- | -------------------------------------------- | --------------------------------------------------------------------- |
| **dnstt**      | `t`       | 1× *(مبنای مقایسه)* | کم                                           | **بیشترین سازگاری با کلاینت‌ها**-- امکان استفاده از کلاینت های مستقل روی بیش از 25 پلتفرم   |
| **Slipstream** | `s`       | 1.5–5×              | متوسط                                        | **استفاده عمومی سریع‌تر**-- در شبکه‌هایی که کلاینت Slipstream در دسترس است |
| **MasterDNS**  | `m`       | تا 9×               | **بالا** *(ARQ + تکرار بسته + چند Resolver)* | **خاموشی‌های شدید**-- به‌صورت بومی در [MahsaNG v16](mahsanet.md)     |
| **XDNS**        | `x`       | ~1×                 | کم                                           | مناسب برای کلاینت‌های FinalMask (Happ, Xray CLI) ؛احراز هویت برای جلوگیری از استفاده غیرمجاز |

**پاسخ کوتاه:** در ایران هنگام محدودسازی شدید یا قطعی اینترنت، **MasterDNS** قوی‌ترین گزینه است و مستقیماً از اپلیکیشن MahsaNG کار می‌کند. در کنار آن **dnstt** را هم ارائه کنید، چون کلاینت آن تقریباً روی همه‌جا اجرا می‌شود.

!!! warning "Resolver سمت کلاینت کلیدی‌تر از خودِ تونل است"
    هر تونل DNS به یک Resolver عمومی (Public Resolver) وابسته است که **کلاینت همچنان بتواند به آن دسترسی داشته باشد**. آدرس‌های معروف مانند `1.1.1.1` و `8.8.8.8` دقیقاً در موقعیت‌هایی که به تونل نیاز دارید، معمولاً با افت سرعت (Throttle) یا انسداد کامل (Null-route) مواجه می‌شوند.

    ابزار XDNS ترافیک را به‌صورت چرخشی (Round-robin) بین `XDNS_RESOLVERS` توزیع می‌کند؛ ابزارهای dnstt و Slipstream نیز یک Resolver را به‌صورت پارامتر (Flag) از سمت کلاینت دریافت می‌کنند. ابزارهای [findns](https://github.com/SamNet-dev/findns) و [dns-mns](https://gitlab.com/E-Gurl/dns-mns) امکان اسکن Resolverهایی را که هنوز در یک شبکه مشخص کار می‌کنند فراهم می‌کنند. برای جزئیات بیشتر به بخش [Resolverهای قابل‌دسترسی](https://www.google.com/search?q=%23reachable-dns-resolvers) مراجعه کنید.

### Resolverهای DNS قابل‌دسترسی (Reachable DNS Resolvers)

عملکرد هر تونل DNS کاملاً وابسته به Resolverی است که **کلاینت می‌تواند به آن دسترسی داشته باشد**. هنگام اختلال یا خاموشی شبکه (Shutdown)، Resolverهای شناخته‌شده (`1.1.1.1`، `8.8.8.8`، `9.9.9.9`) معمولاً دچار افت سرعت (Throttle)، دستکاری ترافیک (Hijack) یا انسداد کامل (Null-route) می‌شوند؛ در نتیجه تونلی که دیروز به‌خوبی کار می‌کرد، ممکن است امروز از کار افتاده به نظر برسد.

دو اسکنر زیر می‌توانند Resolverهایی را که همچنان روی یک شبکه پاسخ‌گو هستند پیدا کنند:

- **[findns](https://github.com/SamNet-dev/findns)**: یک محدوده آدرس را بررسی کرده و Resolverهایی را که پاسخ صحیح می‌دهند گزارش می‌کند.
- **[dns-mns](https://gitlab.com/E-Gurl/dns-mns)**: ایده‌ای مشابه دارد و به‌صورت مستقل نگهداری می‌شود.

 آدرس Resolverهای فعال را در اختیار کلاینت قرار دهید: متغیر `XDNS_RESOLVERS` یک لیست مجزا با کاما (CSV) را می‌پذیرد که XDNS در طول یک Session از mKCP، ترافیک را به‌صورت چرخشی (Round-robin) بین آن‌ها توزیع می‌کند. کلاینت‌های dnstt و Slipstream نیز هر کدام یک Resolver را از طریق آرگومان ورودی (Flag) دریافت می‌کنند. توصیه می‌شود به‌جای یک مورد، دو یا سه Resolver شناخته‌شده و قابل‌دسترسی را در اختیار کاربران قرار دهید.

### dnstt

TCP Stream را با استفاده از KCP + Noise درون Queryهای DNS کدگذاری می‌کند. مسدود کردن آن بدون ایجاد اختلال در خود DNS بسیار دشوار است؛ این روش کندترین گزینه در میان این چهار مورد محسوب می‌شود، اما بیشترین قابلیت حمل (Portability) را دارد.

- **پورت:** `53/udp` *(زیردامنه (Subdomain) `t`)* · **موتور:** [dnstt](https://www.bamsoftware.com/software/dnstt/)
- **کلاینت‌ها:** کلاینت مستقل dnstt روی بیش از 25 پلتفرم
- **نیازمندی:** داشتن دامنه + واگذاری دامنه (NS Delegation)

### Slipstream

همین ایده را از طریق پروتکل **QUIC** پیاده‌سازی می‌کند که بازدهی واقعی  بیشتری فراهم می‌سازد؛ معمولاً ۱.۵ تا ۵ برابر سریع‌تر از dnstt.

- **پورت:** `53/udp` *(زیردامنه(Subdomain) `s`)* ·  **موتور:** [slipstream-rust](https://github.com/Mygod/slipstream-rust) ·   [باینری‌های از پیش ساخته‌شده](https://github.com/net2share/slipstream-rust-build/releases)
- **نیازمندی:** داشتن دامنه + واگذاری دامنه (NS Delegation)

### MasterDNS

مقاوم‌ترین گزینه در برابر افت بسته (Packet Loss) در میان این چهار مورد: بهره‌گیری از ARQ کم‌هزینه، تکرار بسته‌ها و توزیع بار (Load-balancing) بین Resolverها باعث می‌شود حتی روی لینک‌های دارای محدودیت شدید نیز به‌خوبی کار کند. این ابزار همان کامپوننت MasterDNS است که در **MahsaNG v16** پیاده‌سازی شده؛ بنابراین، این اپلیکیشن بدون نیاز به کلاینت مجزا متصل می‌شود.

- **پورت:** `53/udp` *(زیردامنه(Subdomain) برابر `MASTERDNS_SUBDOMAIN`، پیش‌فرض `m`)* · **موتور:** [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) (Go)
- **کلاینت‌ها:** MahsaNG v16+ یا کلاینت مستقل (Linux/Windows/macOS/Termux)
- **رمزنگاری:** AES-256-GCM (`DATA_ENCRYPTION_METHOD=5`)؛ کلید مشترک در Bundle هر کاربر قرار می‌گیرد.
- **قابلیت اضافی:** متغیر `MASTERDNS_PUBLIC_SUBDOMAIN` یک نام واگذاری (Delegation Name) متفاوت از نام استفاده‌شده در داخل منتشر می‌کند؛ باندل‌های (Bundle) تولیدشده نیز از همین نام عمومی استفاده خواهند کرد.

### XDNS (VLESS+mKCP+DNS)

**حالت آزمایشی:** از لایه انتقال (Transport) mKCP در Xray-core به‌همراه FinalMask استفاده می‌کند و تنها تونل DNS در این مجموعه است که **احراز هویت مجزا برای هر کاربر** دارد؛ البته این قابلیت نیازمند کلاینتی است که از FinalMask پشتیبانی کند.

- **پورت:** `53/udp` *(زیردامنه(Subdomain) `x`)* · **موتور:** [Xray-core](https://github.com/XTLS/Xray-core) *(برای FinalMask از Main ساخته شده است)*
- **کلاینت‌ها:** Happ (Beta)، Xray CLI. **فعلاً v2rayNG استاندارد را پشتیبانی نمی‌کند**.
- **بهترین کاربردها:** Telegram و اپلیکیشن‌های Chat سبک، نه برای Browsing سریع

??? note "تنظیمات XDNS"

    | تنظیم | پیش‌فرض | کاربرد |
    |---------|---------|---------|
    | `XDNS_MTU` | `35` | اندازه بسته mKCP. مقدار کمتر = سازگاری با Resolverهای بیشتر. 35 = ایمن‌ترین، 67 = بیشترین مقدار پیشنهادی، 130 = بدون محدودیت |
    | `XDNS_SUBDOMAIN` | `x` | Subdomain مربوط به Queryهای XDNS (`x.yourdomain.com`) |
    | `XDNS_RESOLVERS` | `1.1.1.1,8.8.8.8` | لیست CSV از Public DNS Resolverهایی که کلاینت در یک Session واحد mKCP بین آن‌ها Round-robin انجام می‌دهد (Xray v26.4.13+، [PR #5872](https://github.com/XTLS/Xray-core/pull/5872)). [Resolverهای قابل‌دسترسی](#reachable-dns-resolvers) را ببینید و مقادیر پیش‌فرض را با Resolverهایی که واقعاً در شبکه شما پاسخ می‌دهند جایگزین کنید. خالی گذاشتن آن، به حالت تک‌Resolver برمی‌گردد. |
    | `XDNS_METHOD` | `txt` | حالت Record مربوط به FinalMask در Bundleهای کلاینت تولیدشده. `txt` حالت پیش‌فرض با بیشترین سازگاری است؛ `aaaa` ([Xray #6123](https://github.com/XTLS/Xray-core/pull/6123)) Throughput بیشتری در هر Query فراهم می‌کند، اما **به Xray Client Core نسخه v26.6.1 یا بالاتر نیاز دارد** (Happ / Xray CLI). در سمت سرور نیازی به تغییر نیست. |
    ```

    MTU به طول نام دامنه وابسته است. دامنه کوتاه‌تر امکان استفاده از MTU بالاتر را فراهم می‌کند. مقادیر بالا برای دامنه‌هایی با طول حدود 19 کاراکتر هستند.

    برای سانسور شدید: از `MTU=35` استفاده کنید و از طریق یک DNS Resolver که واقعاً از داخل شبکه سانسورشده قابل‌دسترسی است متصل شوید (به بخش بالا مراجعه کنید).

## انتخاب پروتکل‌ها

**برای شبکه‌های تحت فیلترینگ (ایران، چین، روسیه):**

1. ابتدا از **Reality** شروع کنید — مخفی‌سازی بالایی در برابر تکنیک‌های فیلترینگی که هدف قرار داده دارد و یک گزینه اول قدرتمند برای شبکه‌هایی است که فعلاً روی آن‌ها کار می‌کند.
2. **حالت CDN (CDN Mode)** را اضافه کنید — زمانی کارآمد است که IP سرور شما مسدود شده باشد.
3. **AmneziaWG** را فعال کنید — برای داشتن یک VPN کامل زمانی که ردپای (Fingerprint) پروتکل WireGuard شناسایی می‌شود.
4. **تونل‌های DNS (DNS Tunnels)** را فعال کنید — راهکار نهایی (آخرین گزینه) زمانی که تقریباً همه‌چیز مسدود شده است.


**برای حفظ حریم خصوصی عمومی:**

1. **WireGuard** — سریع‌ترین و ساده‌ترین گزینه
2. **Reality** — زمانی که WireGuard مسدود است

**برای کمک به دیگران:**

1. **Conduit** — اهدای پهنای باند به کاربران Psiphon
2. **Snowflake** — اهدای پهنای باند به کاربران Tor
3. **MahsaNet** — اهدای Configهای VPN به کاربران Mahsa VPN در ایران
