docker build -t waf .
docker run -it -p 127.0.0.1:8080:8080/tcp --rm waf