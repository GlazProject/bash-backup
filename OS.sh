#! /bin/bash

adresFrom=$1
adresTo=$3
ras=$2
md5From=0
md5To=1
i=0
cd || exit


# HELP
if [[ "$1" = "--help" ]]
then
    echo "Use ./OS.sh [adres from] [type] [adres to] -c [count of backups of this type]"
    echo
    echo "Не паникуй, ща всё будет"
    echo "Смотри, вбиваешь полный адрес места, откуда хочешь копировать,"
    echo "потом буквы расширения и после этого полный адрес места,"
    echo "куда хочешь капировать. Не забудь после адреса поставить /"
    echo "Пример: ./OS.sh Desktop/OSi/in/ docx Desktop/ -c 5"
else

while [[ "$md5From" != "$md5To" ]]
do
    date=$(date +"%H:%M:%S %d.%m.%Y")
    name="$adresTo""Backup of [""$ras""] ""$date"".bac"
    # create copy in zip and replace it in directory
    cd "$adresFrom" || exit
    zip -9q temporary.zip $(find . -name "*""$ras")
    cd || exit
    cp "$adresFrom""temporary.zip" "$name"
    rm "$adresFrom""temporary.zip"

    # create and chek md5sum
    md5From=($(md5sum "$adresFrom"*".""$ras"|sort))
    mkdir "/home/kali/temporary"
    unzip -q "$name" -d "/home/kali/temporary/"
    md5To=($(md5sum "/home/kali/temporary/"*|sort))
    rm -Rf "/home/kali/temporary/"
    ((i++)) || true
    echo "Попытка номер: ""$i"
    # echo $md5From
    # echo $md5To

    if [[ $i -gt 10 ]]
    then
        break
    else
        continue
    fi
done


if [[ $i -le 10 ]]
then
    echo "Всё хорошо, мы успешно сделали сохранение в файл /""$name"
else
    echo "У меня не получилось сделать сохранение"
fi


# delete oldest backup
if [[ "$4" = "-c" ]]
then
    if [[ "$5" = "" ]]
    then
        echo
        echo "Вы должны вписать количество резервных копий для удаления старых"
        echo "Use ./OS.sh --help for information"
    else
        maxCount=$5
        count=$(ls "$adresTo""Backup of [""$ras""] "*".bac" | wc -l)
        ((count=$count-$maxCount))
        i=$count
        for file in "$adresTo""Backup of [""$ras""] "*".bac"
        do
            if [[ $count  > 0 ]]
            then    
                ((count--))
                rm "$file"
            else
                break
            fi
        done
        echo "Успешно удалено ""$i"" устаревших копий"
    fi
fi


fi