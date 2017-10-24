#!/usr/bin/env bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

gex_env="${gex_env:-$1}"

[[ -z "${gex_env}" ]] && {
    echo -e "${RED}gex_env is unset${NC}";
    echo -e "Usage: ${YELLOW}./run_gush \$gex_env ${NC}"
    exit 1
}

n_threads=10
queue='provisiongush'


gex_env=${gex_env} bundle exec sidekiq -r ./Gushfile.rb -c ${n_threads} -q ${queue} -e development -v