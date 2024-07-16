---
title: "Ferris Pcb Padge"
date: 2024-01-13T00:59:08+01:00
draft: true
---

In the last evenings I created my first PCB badge containing electronics.[^1]

We want to host a small event in our local hackspace and it looks
like I catched the hat for the badge team.
But we don't have any fancy logo yet and I need some experience before.

[^1]: I created a badge without electronics before, which is comparably not as fancy.

## Graphical Design in KiCad

So first thing I need is a motive.
As the firmware will be written in Rust and Rust has a cute mascot, [Ferris],
I downloaded the SVG of the logo and tried converting that to a PCB.

KiCad can import bitmaps, but you can only use them on the silkscreen or the copper layer.

So I tried an external tool, [svg2shenzen], which is a plugin for [Inkscape].

[Ferris]: https://rustacean.net/
[svg2shenzen]: https://github.com/badgeek/svg2shenzhen

## Chip selection

I want to develop the firmware in Rust using the embassy ecosystem if possible.
For that, the STM32 series microcontrollers are a nice fit.
My manufacturer has lot's of models of them in stock for a cheap price,
so I choose them.

For the badge I have some requirements:

- PWM with 4 channels
- low power if off and during operation
- cheap
- small

I did choose the STM32L031G6U6 in the end.
It does have one 4 channel timer that can be used for the LEDs,
but that is already used by embassy for scheduling tasks.
So we use two timers, each containing two output channels,
for the LEDs instead.

## Firmware

As mentioned before, I want to develop the firmware in Rust using the embassy framework.
