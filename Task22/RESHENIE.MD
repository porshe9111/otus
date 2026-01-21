## Lesson32 - Статическая и динамическая маршрутизация, OSPF

<details>

### Задача:

1. Развернуть 3 виртуальные машины
2. Объединить их разными vlan
- настроить OSPF между машинами на базе Quagga;
- изобразить ассиметричный роутинг;
- сделать один из линков "дорогим", но что бы при этом роутинг был симметричным.


Формат сдачи ДЗ - vagrant + ansible

### Решение:

**Схема сети**

![Image 1](Lesson32_OSPF/screen/Network_scheme.jpg)

Разворачиваем роутеры через Vagrant и Ansible и проверяем доступность сетей с разных хостов.

![Image 1](Lesson32_OSPF/screen/r1proof.jpg)

![Image 1](Lesson32_OSPF/screen/r2proof.jpg)

![Image 1](Lesson32_OSPF/screen/r3proof.jpg)

## Настройка и проверка ассиметричного роутинга


```
root@router1:~# vtysh

Hello, this is FRRouting (version 8.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# conf t
router1(config)# int enp0s8 
router1(config-if)# ip ospf cost 1000
router1(config-if)# exit
router1(config)# exit
```
![Image 1](Lesson32_OSPF/screen/OSPF_weight1.jpg)

![Image 1](Lesson32_OSPF/screen/OSPF_weight2.jpg)


## Настройка и проверка симетричного роутинга с дорогими интерфейсами

```
router2# conf t
router2(config)# int enp0s8
router2(config-if)# ip ospf cost 1000
router2(config-if)# exit
router2(config)# exit
```
![Image 1](Lesson32_OSPF/screen/OSPF_sim1.jpg)

![Image 1](Lesson32_OSPF/screen/OSPF_sim2.jpg)

</details>

