# MKS TFT28 V2.0 / TFT32_L V3.0 — Firmware PanelDue para Klipper/Voron 2.4

> [English version](README.md)

![MKS TFT28 V2.0 rodando firmware PanelDue com Klipper](display_working.jpg)

## Hardware

| Item | Valor |
|------|-------|
| Board | MKS TFT28 V2.0 (silk screen: MKS TFT32_L V3.0) |
| MCU | STM32F107VCT6 (chipid 0x418, Cortex-M3, 256KB flash) |
| Display | H685, 320×240, TN normally-white |
| Controlador LCD | **R61505** (ID=0x1505 lido via R00h) |
| Touch | XPT2046 via SPI3 |
| EEPROM | I2C físico (separado da flash STM32) |
| Protocolo | PanelDue (robotsrulz/MKS-TFT base) |

---

## Como gravar

### Hardware necessário

**Programador ST-Link V2** — clones baratos (~R$20) funcionam bem.

### Conexão SWD

Conecte o ST-Link no conector JTAG de 6 pinos da placa (canto superior direito, marcado como `JTAG`):

| Pino JTAG | Sinal | ST-Link |
|-----------|-------|---------|
| 1 | GND | GND |
| 2 | NRST | — (não necessário) |
| 3 | GND | GND |
| 4 | JTCK / SWDCLK | SWDCLK |
| 5 | +3V3 | (ver nota de alimentação abaixo) |
| 6 | JTMS / SWDIO | SWDIO |

> **Alimentação:** use apenas uma fonte — nunca duas ao mesmo tempo:
> - Placa conectada à impressora → conecte apenas os pinos 1, 4, 6 (GND, SWDCLK, SWDIO)
> - Placa desconectada da impressora → pode conectar também o pino 5 (+3V3) do ST-Link, mas **nunca conecte 5V** (a placa opera em 3.3V)

---

### Opção A — Windows (STM32CubeProgrammer)

1. Baixe e instale o [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html) (gratuito, ferramenta oficial da ST)
2. Conecte o ST-Link no USB e na placa
3. Abra o STM32CubeProgrammer → selecione **ST-LINK** → clique em **Connect**
4. Vá em **Erasing & Programming**
5. Selecione o arquivo `MKS-TFT32_voron24_klipper.bin`
6. Defina o endereço inicial como `0x08000000`
7. Marque **Verify programming** e **Run after programming**
8. Clique em **Start Programming**

---

### Opção B — macOS / Linux (OpenOCD)

Instale o OpenOCD:
```bash
# macOS
brew install openocd

# Ubuntu/Debian
sudo apt install openocd
```

Execute na pasta onde está o arquivo `.bin`:

```bash
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
  -c "program MKS-TFT32_voron24_klipper.bin verify reset exit 0x08000000"
```

---

### Opção C — Pelo próprio Raspberry Pi do Klipper

Se o ST-Link estiver conectado na USB do Pi, grave diretamente de lá (sem computador separado):

```bash
sudo apt install openocd
cd ~
wget https://github.com/rescosta/MKS-TFT/raw/r61505-stm32f107-klipper/binaries/MKS-TFT32_voron24_klipper.bin
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
  -c "program MKS-TFT32_voron24_klipper.bin verify reset exit 0x08000000"
```

---

### Saída esperada (Opções B e C)

```
** Programming Started **
** Programming Finished **
** Verify Started **
** Verified OK **
** Resetting Target **
```

Se aparecer `Verified OK`, a placa reinicia automaticamente e a interface PanelDue aparece no display.

> **Importante:** **não use `st-flash` diretamente** — ele tem problemas conhecidos com o STM32F107 e pode reportar sucesso sem ter gravado corretamente.

---

## Conexão com Klipper

### 1. Fiação física

O MKS TFT28 V2.0 possui um conector serial de 4 pinos (TTL 3.3V) identificado como **EXP** ou **RS232** na placa:

| Pino TFT28 | Sinal | Conecta em |
|------------|-------|------------|
| TX | Transmite dados | RX do Raspberry Pi / SBC |
| RX | Recebe dados | TX do Raspberry Pi / SBC |
| GND | Terra | GND do Raspberry Pi / SBC |
| 5V / 3.3V | Alimentação | (opcional — pode alimentar pelo próprio conector da impressora) |

> **Atenção:** TX do TFT vai no RX do Pi e vice-versa. Níveis TTL 3.3V — não conectar em porta RS232 de 12V.

#### Opção A — UART GPIO do Raspberry Pi

Conectar TX/RX/GND nos pinos físicos do GPIO:

| GPIO Pi | Pino físico | Função |
|---------|------------|--------|
| GPIO14 | Pino 8 | TXD (→ RX do TFT) |
| GPIO15 | Pino 10 | RXD (← TX do TFT) |
| GND | Pino 6 ou 14 | GND |

Dispositivo serial resultante: `/dev/ttyAMA0` (Pi 3/4) ou `/dev/ttyS0`

Habilitar UART no Pi (se necessário):
```bash
# /boot/config.txt
enable_uart=1
dtoverlay=disable-bt   # libera UART0 do Bluetooth (Pi 3/4)
```

#### Opção B — Adaptador USB-TTL

Conectar via adaptador USB-to-serial (CP2102, CH340, FTDI). O dispositivo aparece como `/dev/ttyUSB0` ou similar.

#### Identificar o serial correto

```bash
ls /dev/tty{USB,AMA,S}*
# ou
dmesg | grep tty
```

---

### 2. Configuração Moonraker

```ini
# moonraker.conf
[paneldue]
serial: /dev/ttyS5        # ajustar conforme o dispositivo detectado
baud: 57600
machine_name: Voron 2.4
macros:
  LOAD_FILAMENT
  UNLOAD_FILAMENT
confirmed_macros:
  RESTART
  FIRMWARE_RESTART
```

---

### 3. Configuração printer.cfg

Adicionar ao `printer.cfg`:

```ini
# Macro obrigatória para o PanelDue emitir bips
[gcode_macro PANELDUE_BEEP]
gcode:
    {% set FREQUENCY = params.FREQUENCY|default(300)|int %}
    {% set DURATION = params.DURATION|default(1.0)|float %}
    M300 S{FREQUENCY} P{(DURATION * 1000)|int}

# Macros opcionais — aparecem nos botões de macro do PanelDue
[gcode_macro LOAD_FILAMENT]
gcode:
    M83
    G1 E50 F300
    G1 E30 F150
    M82

[gcode_macro UNLOAD_FILAMENT]
gcode:
    M83
    G1 E10 F300
    G1 E-80 F800
    M82
```

> Se a impressora não tiver buzzer (`M300`), a macro `PANELDUE_BEEP` pode ficar vazia — o PanelDue funciona normalmente sem som.

---

### 4. Reiniciar serviços

```bash
sudo systemctl restart moonraker
sudo systemctl restart klipper
```

O display deve mostrar **"Connecting"** por alguns segundos e depois exibir os dados da impressora (temperatura, posição, etc.).

---

## Registradores R61505 — configuração final

Valores extraídos por disassembly ARM Thumb-2 do firmware original MKS (mkstft28.bin v3.0.2).

### Startup (antes de R01h)

| Registrador | Valor | Descrição |
|-------------|-------|-----------|
| R0E5h | 0x8000 | Startup R61505 (proprietário) |
| R00h  | 0x0001 | Start oscillator |

### Power

| Registrador | Valor | Descrição |
|-------------|-------|-----------|
| R10h | 0x17B0 | Power Control 1: SAP=1, BT=7, APE=1 |
| R11h | 0x0037 | Power Control 2: DC1=3, DC0=0, VC=7 |
| R12h | 0x0138 | Power Control 3: VRH=8, PON=1, VCIRE=1 |
| R13h | 0x1700 | Power Control 4: VDV=23 |
| R29h | 0x001F | VCOMH=31 |
| R61h | 0x0001 | REV=1 (polaridade invertida) |

### Gamma (R30h–R3Dh)

```
R30h=0x0707  R31h=0x0007  R32h=0x0603
R33h=0x0700  R34h=0x0202  (R61505 não-documentados)
R35h=0x0002
R36h=0x1F0F  (VRP1=31 — amplitude máxima)
R37h=0x0707  R38h=0x0000  R39h=0x0000
R3Ah=0x0707  R3Bh=0x0000  (R61505 não-documentados)
R3Ch=0x0007  R3Dh=0x0000
```

### Panel Interface

```
R90h=0x0010  R92h=0x0000  R93h=0x0003
R95h=0x0101  R97h=0x0000  R98h=0x0000
```

### Display turn-on (R07h)

```
R07h=0x0021 → delay 50ms → R07h=0x0031 → delay 50ms → R07h=0x0173
```

### Orientação e BGR

| Parâmetro | Valor |
|-----------|-------|
| DisplayOrientation | ReverseX \| SwapXY (0x03) |
| R01h | SS=0, SM=0 |
| R03h | AM=1, BGR=1 (bit 12), I/D=11 |
| R60h | GS=0, NL=0x27 (320 linhas) |

---

## Touch

- Controlador: XPT2046 via SPI3
- Orientação padrão: SwapXY (0x01)
- Calibração salva no EEPROM (magicVal=0x3AB629D7)
- A calibração persiste entre gravações (EEPROM não é apagado pelo mass erase)

---

## Backlight

- PWM via TIM4_CH3 (PD14), 1kHz
- AFIO full remap habilitado (`__HAL_AFIO_REMAP_TIM4_ENABLE()`)
- Brilho: 100% (`lcd.setBacklightBrightness(100)` em `Src/PanelDue.cpp`)

---

## Toolchain

```
/opt/homebrew/Cellar/arm-gcc-bin@10/10.3-2021.10_1/bin/arm-none-eabi-gcc
```

```bash
# Compilar
make

# Gravar
make flash
# ou
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
  -c "program build/MKS-TFT32.bin verify reset exit 0x08000000"
```

---

## Defines necessários (Makefile)

```makefile
DEFS = -DSTM32F107xC -DMKS_TFT -DILI9328 -DR61505 -DUSE_HAL_DRIVER
```

---

## Status

| Função | Estado |
|--------|--------|
| Orientação display | ✓ Correto |
| Touch | ✓ Funcional (auto-calibração) |
| Backlight PWM | ✓ Funcional |
| Comunicação Klipper (PanelDue) | ✓ Configurado |
| Vivacidade de cores | ✓ Correto — cores vivas, confirmado |
| Scan lines | ✓ Ausentes |
