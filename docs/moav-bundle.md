# The `moav://` bundle

Every MoaV user bundle's `subscription.txt` carries a single **`moav://`** line: a
compact URL that encodes the user's entire enabled proxy surface at once,
alongside the usual per-protocol share links (`vless://`, `trojan://`, …).

The `moav://` line is **additive** — it sits next to the legacy URIs, not in
place of them:

- **[MoaV Client](client.md)** recognizes the line, expands it back into one
  endpoint per protocol, and de-duplicates it against the legacy URIs (by
  protocol + address), so importing a subscription yields each server once.
- Every other client ignores the unknown `moav://` scheme and uses the legacy
  URIs. Nothing regresses.

## Why

A MoaV subscription is N separate URIs that repeat the same host, UUID, Reality
keypair, and passwords for every protocol. The `moav://` form factors the shared
parts out once, so the bundle is far smaller and rotating a shared credential is
a one-line change instead of editing every URI.

## Using it

There's nothing to configure. When you provision or regenerate a user, the
server writes the `moav://` line into that user's `subscription.txt` (and it
flows into the base64 subscription automatically). To use it, just import your
subscription into the MoaV Client the way you already do — paste the
subscription, its URL, or drop the server `.zip`. See
[MoaV Client → Install](client.md#install).

## Format

```text
moav://<uuid>@<server-host>?<shared>&p=<record>&p=<record>…#<label>
```

- **`<uuid>`** (userinfo) — the VLESS UUID; applies to every `vless-*` record.
- **`<shared>`** — flat query params common to several protocols, each value
  percent-encoded: `pw`, `pbk`, `sid`, `sni_default`, `fp`, `ss_method`,
  `ss_pw`, `obfs_pw`.
- **`p=<record>`** — one per enabled protocol: `p=<name>,<port>[,k=v…]`. The
  commas and `=` inside a record are structural; sub-values are percent-encoded.

### Records, per protocol

| Protocol | `p=` record | Shared keys used |
|---|---|---|
| Reality | `p=reality,443,sni=…,flow=xtls-rprx-vision` | `pbk`, `sid` |
| XHTTP | `p=vless-xhttp,<port>,sni=…,fp=chrome` | `pbk`, `sid` |
| CDN | `p=vless-ws` or `p=vless-httpupgrade` `,443,host=…,path=…,sni=…,alpn=http/1.1` | — |
| Trojan | `p=trojan,8443` | `pw`, `sni_default` |
| AnyTLS | `p=anytls,<port>` | `pw`, `sni_default` |
| Hysteria2 | `p=hy2,443,obfs=salamander` | `pw`, `sni_default`, `obfs_pw` |
| Shadowsocks-2022 | `p=ss,<port>` | `ss_method`, `ss_pw` |

The CDN record's transport (`vless-ws` vs `vless-httpupgrade`) follows the
server's `CDN_TRANSPORT`.

## Reference

The full format specification lives in the repositories:
[server](https://github.com/MotherofallVPNs/moav/blob/main/docs/MOAV_BUNDLE.md)
(the emitter) and
[moav-client](https://github.com/MotherofallVPNs/moav-client/blob/main/docs/MOAV_BUNDLE.md)
(the parser).
