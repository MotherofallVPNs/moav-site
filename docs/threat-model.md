# Threat Model

MoaV is useful because it improves access resilience. It does not make every user anonymous against every adversary.

This page explains what MoaV is designed to protect, what it does not protect, and what operators should assume before deploying it.

## Who MoaV is meant to help

MoaV is designed for:

- people in censored environments who need access to the open internet
- journalists, civil-society groups, activists, students, and families affected by blocking
- diaspora communities that can provide trusted technical support
- operators who can safely run servers outside high-risk jurisdictions

## Adversaries

MoaV assumes adversaries may include:

- state censors blocking domains, IPs, protocols, app stores, and payment routes
- network operators performing DPI, throttling, or traffic shaping under state pressure
- active probers that connect to suspected proxy servers
- hosting providers that may suspend nodes after complaints
- attackers targeting users, operators, or project infrastructure
- malicious operators pretending to run trusted nodes

## What MoaV tries to protect

MoaV tries to improve:

- access to blocked websites and services
- availability of fallback routes during blocking events
- operator ability to deploy and rotate nodes quickly
- integrity of open-source deployment scripts and documentation
- user safety through clear limits and safer defaults

## What MoaV does not fully protect

MoaV does not fully protect against:

- device compromise
- targeted surveillance by a capable state actor
- unsafe user behavior after connecting
- metadata exposure from the local network, hosting provider, payment system, or destination service
- trust problems caused by unknown or malicious node operators
- legal risk for operators in hostile jurisdictions

If a user's device is compromised, a network tool cannot make that device safe. If an operator is in a jurisdiction where running circumvention infrastructure is dangerous, MoaV does not remove that legal or physical risk.

## Metadata risks

Even when traffic content is encrypted, metadata can remain visible. Examples include:

- server IP addresses
- connection timing
- protocol choice
- traffic volume
- cloud-provider billing records
- operator logs
- destination-side account activity

MoaV should minimize unnecessary logs and make safer defaults easy, but operators remain responsible for how they host, monitor, and share access.

## Operator safety principles

Operators should:

- run nodes only where they can safely do so
- avoid publishing sensitive node inventory
- use unique credentials per user
- revoke compromised users quickly
- keep admin panels locked down
- avoid unnecessary logging
- keep systems updated
- separate personal identity from operational infrastructure where possible
- read the [OPSEC Guide](OPSEC.md)

## User safety principles

Users should:

- get configs only from trusted sources
- keep devices updated
- avoid logging into high-risk personal accounts when unnecessary
- assume local network observers may see that they are using unusual traffic
- understand that MoaV provides access, not total anonymity

## Misuse and abuse

Any access tool can be used outside its intended beneficiary group. MoaV's answer is transparency and careful operation, not centralized surveillance.

The project should avoid collecting user identities, avoid building unnecessary tracking features, and keep deployment auditable. Public operators should still have abuse-response plans and should understand the policies of their hosting providers.

## Public reporting

Do not publish live operational details that could help censors block active users. Public reports should focus on aggregate progress, security fixes, documentation, and reusable open-source outputs.

## Related pages

- [OPSEC Guide](OPSEC.md)
- [Architecture](architecture.md)
- [Supported Protocols](protocols.md)
- [Mission](mission.md)

