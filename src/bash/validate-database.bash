#!/bin/bash
LEXFILE=lexemes.tsv
WORK=$(mktemp -d -t omorfi-validate-database.XXXXXXXXXX)
if test -f ${WORK}/duplicate-keys ; then
    rm -v duplicate-keys
fi

echo "checking for duplicate unique keys in lexemes (word_id, homonym)"
echo ${LEXFILE}...
cut -f 1,2 ${LEXFILE} | LC_ALL=C sort > ${WORK}/keys
LC_ALL=C uniq -c < ${WORK}/keys |\
    awk '$1 > 1 {print;}' > ${WORK}/duplicate-keys
if test -s ${WORK}/duplicate-keys ; then
    echo ${LEXFILE} has duplicate keys in ${WORK}/duplicate-keys
    exit 1
fi
echo checking for broken joins
sort < ${WORK}/keys > ${WORK}/lc-sort-keys
for f in attributes/*.tsv ; do
    echo $f...
    cut -f 1,2 $f | sort | uniq > ${WORK}/keys.$(basename $f)
    comm -23 ${WORK}/keys.$(basename $f) ${WORK}/lc-sort-keys > ${WORK}/missing-keys.$(basename $f)
    while read k ; do
        echo MISSING $k is not found in ${LEXFILE} but is in $f >> ${WORK}/fails.$(basename $f)
        egrep -- "^${k/+/\\+}[[:space:]]" $f >> ${WORK}/fails.$(basename $f)
        echo LOOK FOR $k in ${LEXEMES} >> ${WORK}/fails.$(basename $f)
        egrep -- "^$(echo $k | awk '{print $1}')[[:space:]]" ${LEXFILE} >> ${WORK}/fails.$(basename $f)
    done < ${WORK}/missing-keys.$(basename $f)
    if test -e ${WORK}/fails.$(basename $f) ; then
        echo
        echo there were inconsistencies in ${f}, see ${WORK}/fails.$(basename $f)
        exit 1
    fi
done
rm -rf ${WORK}
