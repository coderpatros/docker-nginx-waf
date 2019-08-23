![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/coderpatros/nginx-waf)
![Docker Pulls](https://img.shields.io/docker/pulls/coderpatros/nginx-waf.svg)
[![](https://images.microbadger.com/badges/image/coderpatros/nginx-waf.svg)](https://microbadger.com/images/coderpatros/nginx-waf "Get your own image badge on microbadger.com")
![GitHub](https://img.shields.io/github/license/patros/docker-nginx-waf)

# NGINX WAF Docker Container

This is an unofficial build of the NGINX web application firewall.

NGINX WAF is NGINX coupled with ModSecurity 3.0.

## Tags

There are currently two moving tags, `latest` and `1-latest`.

I recommend tracking `1-latest` as I won't add any breaking changes to it.

## Usage

There are a couple of ways you can use this image.

The easiest way is to mount a volume containing your NGINX config files as
`/etc/nginx/conf.d`.

The other option is to use this as a base image and copy your config into a
custom image.

And don't forget to mount a volume for `/var/log`.

## Environment Variables

`SEC_RULE_ENGINE` is used to override the `SecRuleEngine` setting. It defaults
to `On` but can also be set to `DetectionOnly`.
