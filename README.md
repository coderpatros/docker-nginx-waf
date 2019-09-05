![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/coderpatros/nginx-waf)
![Docker Pulls](https://img.shields.io/docker/pulls/coderpatros/nginx-waf.svg)
[![](https://images.microbadger.com/badges/image/coderpatros/nginx-waf.svg)](https://microbadger.com/images/coderpatros/nginx-waf "Get your own image badge on microbadger.com")
![GitHub](https://img.shields.io/github/license/patros/docker-nginx-waf)

# NGINX WAF Docker Container

This is a production ready, unofficial build of the NGINX web application firewall.

NGINX WAF is NGINX coupled with ModSecurity 3.0.

## Tags

There are currently four moving tags, `latest`, `stable`, `mainline` and `dev`.

`stable` is the recommended tag to use. Builds with this tag have passed both
functional and performance tests.

`mainline` has passed functional tests, but not performance tests.

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

And it takes about 20 minutes to build the container and run tests for pull requests.