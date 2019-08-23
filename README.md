![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/coderpatros/nginx-waf)
![Docker Pulls](https://img.shields.io/docker/pulls/coderpatros/nginx-waf.svg)
![GitHub](https://img.shields.io/github/license/patros/docker-nginx-waf)

# NGINX WAF Docker Container

This is an unofficial build of the NGINX web application firewall.

NGINX WAF is NGINX coupled with ModSecurity 3.0.

## Usage

There are a couple of ways you can use this image.

The easiest way is to mount a volume containing your NGINX config files as
`/etc/nginx/conf.d`.

The other option is to use this as a base image and copy your config into a
your custom image. This certainly gives you much more flexibility and control.

And don't forget to mount a volume for `/var/log`.

## Environment Variables

`SEC_RULE_ENGINE` is used to override the `SecRuleEngine` setting. It defaults
to `On` but can also be set to `DetectionOnly`.