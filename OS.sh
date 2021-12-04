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
    echo "Эта программа позволяет создавать резервные копии файлов с заданным расширением."
    echo "Для создания копии необходипо обязательно указать папку из которой нужно сохранить файлы, нужное расширение файлов, и папку, в которую сохранить резервную копию."
    echo "Опционально можно указать количество активных резервных копий, при этом старые копии удалятся."
    echo "Пример для создания резервных копий файлов ворд: ./OS.sh ./Desktop/OSi/in/ docx ./Desktop/"
    echo "Пример для создания резервных копий файлов ворд с сохранением последних пяти: ./OS.sh ./Desktop/OSi/in/ docx ./Desktop/ -c 5"
    exit 0
else

if [[ "$1" = "" ]] || [[ "$2" = "" ]] || [[ "$3" = "" ]]
then
    echo "Введена неверная команда"
    echo "Используйте ./OS.sh --help для вывода информации и инструкции"
    exit 2
fi

while [[ "$md5From" != "$md5To" ]]
do
    date=$(date +"%H:%M:%S %d.%m.%Y")
    name="$adresTo""Backup of [""$ras""] ""$date"".bac"

    # create copy in zip and replace it in directory
    cd "$adresFrom" || exit
    zip -9q "temporary.zip" $(find . -name "*""$ras")
    cd || exit
    cp "$adresFrom""temporary.zip" "$name"
    rm "$adresFrom""temporary.zip"

    # create and chek md5sum
    IFS=" " read -r -a md5From <<< "$(md5sum "$adresFrom"*".""$ras"|sort)"
    mkdir "/home/kali/temporary"
    unzip -q "$name" -d "/home/kali/temporary/"
    IFS=" " read -r -a md5To <<< "$(md5sum "/home/kali/temporary/"*|sort)"
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
    exit 1
fi


# delete oldest backup
if [[ "$4" = "-c" ]]
then
    if [[ "$5" = "" ]]
    then
        echo
        echo "Вы должны указать количество резервных копий для удаления старых"
        echo "Используйте ./OS.sh --help для вывода информации и инструкции"
        exit 2
    else
        maxCount=$5
        count=$(ls "$adresTo""Backup of [""$ras""] "*".bac" | wc -l)
        ((count=count-maxCount))
        i=$count
        for file in "$adresTo""Backup of [""$ras""] "*".bac"
        do
            if [[ $count  -gt 0 ]]
            then    
                ((count--))
                rm "$file"
            else
                break
            fi
        done
        echo "Успешно удалено ""$i"" устаревших копий"
        exit 0
    fi
fi
exit 0

fi