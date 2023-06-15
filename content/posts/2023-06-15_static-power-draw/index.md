+++ 
draft = false
title = "Do You Know the Power Intake of Your Computer?"
showTableOfContents = false
issueId = 2
+++

As part of my master's thesis I measured the power usage of my computer system.[^1]
For the measurement I was granted with a professional hardware measurement tool which was capable of measuring the power intake of my computer system accurately. 
The facinating thing I've noticed was that my day-to-day tower computer does by far not demand as much power as I was initially thinking. I don't own a massive gaming computer with absolutely blasting specs, but I still expected a way higher power draw.
For reference my setup consists of the following parts:

- Motherboard: Asus TUF Gaming B550M-Plus (Wi-Fi)
- CPU: AMD Ryzen 7 PRO 4750G
- RAM: 2x 16GB 2133 Mhz G-Skill F4-3200C16-16GIS, 2x 8GB 2133 Mhz G-Skill F4-3200C16-8GIS
- GPU: AMD Radeon RX 6600
- SSD: Samsung 850 EVO

On a fresh Ubuntu Server 22.10 installation I measured exactly 33W power draw during idle mode. The facinating thing was that even when I pushed the CPU to the limit, I've barley surpassed a power draw of 100W.[^2]

This means, that it would be easily possible to power my computer with a single solar module assuming a pessimistic watt peak of 100W (A quick google search told me that a [350 watt peak is possible to achieve with a single module](https://www.gasag.de/magazin/nachhaltig/photovoltaik-leistung-ermitteln)). 
Even accounting that I only measured the power draw of my computer ignoring the displays and periphery I find this kinda astonishing.

[^1]: In the thesis I'm using the energy consumption of a computer system as an approximation for carbon emissions. Maybe I get more in the detail in a later post.
[^2]: I measured how the power draw behaves when I push certain components to the limit. The result is kinda interesting and I will probably post about it once all formalities regarding my thesis are done. 