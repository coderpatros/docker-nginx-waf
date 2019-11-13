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

## NGINX Amplify

This image includes the NGINX Amplify agent.

To make enable the agent you need to set the `AMPLIFY_API_KEY` environment
variable and optionally the `AMPLIFY_IMAGENAME` variable
(defaults to "Web Application Firewall").

## Tests

_Functional tests_ perform a sequence of requests to validate that the rule
engine is working as configured. i.e. dodgy requests are being blocked, normal
requests are being allowed.

_Performance tests_ time how long it takes to make 250,000 requests. The time
taken is compared to previous baseline runs from the stable branch. This is to
ensure no unexpected performance regressions creep in.

_Burn in_ tests are the same as performance tests except 10,000,000 requests are
made.

## Usage

There are a couple of ways you can use this image.

For example config refer to [tests/nginx-conf.d/example.conf](tests/nginx-conf.d/example.conf).

The easiest way is to mount a volume containing your NGINX config files as
`/etc/nginx/conf.d`.

The other option is to use this as a base image and copy your config into a
custom image.

Mounting a volume makes it easier to get going. Although if you build your own
image you get the benefits of having your configuration in source control.

The other important aspect of using this is application tuned ModSecurity
config files. There are two base config files `modsec.conf` and
`modsec-detectiononly.conf`. But you should create custom ModSecurity config
files for each application you are protecting.

This allows you to fine tune the rules that are enabled. For example there is no
point processing PHP specific rules for Java or c# apps. These can be disabled
by using the `SecRuleRemoveByTag` directive. For example
`SecRuleRemoveByTag "language-php"` will disable rules specific to PHP apps.

You will additionally need to fine tune the enabled rules for application
specific false positives. The `SecRuleRemoveById` directive will allow you to
disable specific rules that are false positives for your application.

And don't forget to mount a volume for `/var/log`.

## Example NGINX Config Files

I'm putting example config files under [example-conf](example-conf).

Copy what you want into your `/etc/nginx/conf.d` volume.

## Contributing

I'm more than happy to receive contributions.

But if you have an idea please create an issue first so we can discuss it.

It takes about 30 minutes to build the container and run functional and
performance tests for pull requests to master.

Subsequent pull requests to the stable branch trigger the burn in tests. These
take about 5 hours. So it might take some time for changes in the `mainline`
image to make it into the `stable` image.