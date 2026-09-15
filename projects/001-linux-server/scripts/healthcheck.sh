#!/bin/bash

STATUS=0

echo "=================================="
echo " CloudJourney - Health Check"
echo "=================================="
echo
echo "Hostname:"
hostname

echo
echo "Data e hora:"
date

echo
echo "Uso de memória:"
free -h

echo
echo "Uso de disco:"
df -h /

echo
echo "Status do Nginx:"
if systemctl is-active --quiet nginx; then
    echo "Nginx: OK"
else
    echo "Nginx: ERRO"
    STATUS=1
fi

echo
echo "Validação das portas:"
if ss -ltn | grep -q ':22'; then
    echo "Porta 22: OK"
else
    echo "Porta 22: ERRO"
    STATUS=1
fi

if ss -ltn | grep -q ':80'; then
    echo "Porta 80: OK"
else
    echo "Porta 80: ERRO"
    STATUS=1
fi

exit $STATUS
