![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/coderpatros/nginx-waf)
![Docker Pulls](https://img.shields.io/docker/pulls/coderpatros/nginx-waf.svg)
[![](https://images.microbadger.com/badges/image/coderpatros/nginx-waf.svg)](https://microbadger.com/images/coderpatros/nginx-waf "Get your own image badge on microbadger.com")
![GitHub](https://img.shields.io/github/license/patros/docker-nginx-waf)

# NGINX WAF Docker Container

This is a production ready, unofficial build of the NGINX web application firewall.

NGINX WAF is NGINX coupled with ModSecurity 3.0.

## Tags

There are currently three moving tags, `stable`, `mainline` and `latest`.

`stable` is the recommended tag to use. Builds with this tag have passed
functional, performance and burn in tests. It is paired to the `stable` branch.

`mainline` has passed functional and performance tests, but not burn in tests.
It is paired to the `master` branch.

## Tests

_Functional tests_ perform a sequence of requests to validate that the rule
engine is working as configured. i.e. dodgy requests are being blocked, normal
requests are being allowed.

_Performance tests_ time how long it takes to make 250,000 requests. The time
taken is compared to previous baseline runs from the stable branch. This is to
ensure no unexpected performance regressions creep in.

_Burn in_ tests are run for 5 hours. They just make as many requests as
possible during that time.

## Usage

There are a couple of ways you can use this image.

The easiest way is to mount a volume containing your NGINX config files as
`/etc/nginx/conf.d`.

The other option is to use this as a base image and copy your config into a
custom image.

And don't forget to mount a volume for `/var/log`.

## Environment Variables

Variable | Purpose | Options | Default
--- | --- | --- | ----
`SEC_AUDIT_ENGINE` | Override the `SecAuditEngine` ModSecurity setting. | `On`, `Off`, `RelevantOnly` | `Off`
`SEC_RULE_ENGINE` | Override the `SecRuleEngine` ModSecurity setting. | `On`, `Off`, `DetectionOnly` | `On`

## Contributing

I'm more than happy to receive contributions.

But if you have an idea please create an issue first so we can discuss it.

And it takes about 30 minutes to build the container and run functional and performance tests for pull requests.