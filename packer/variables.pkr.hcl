#  "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }
