# Gust parser

## Install
```
git clone
bundle install
sudo apt-get install phantomjs
```

## ENV

Set the environment variables (~/.zshrc || ~/.bashrc)

```
export GUSTPARSER_EMAIL="email"
export GUSTPARSER_PASSWORD="password"
```

## Run

```
rake initilize  # init sqlite db
rake parse
```
