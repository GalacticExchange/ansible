#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

#gex_env='main'
gex_env=$1
n_threads=10
queue='provisiongush'


_gex_env=${gex_env} bundle exec sidekiq -r ./Gushfile.rb -c ${n_threads} -q ${queue} -e development -v