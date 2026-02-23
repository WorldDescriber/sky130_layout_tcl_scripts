# Sky130 Layout TCL Scripts

A collection of TCL scripts for device layout generation in the SkyWater 130nm open source PDK. This project enables programmatic creation of custom device layouts using TCL scripting with Magic VLSI layout tool.

## 🎯 Overview

This repository contains TCL scripts that half-automate the generation of semiconductor device layouts for the Sky130 process. By leveraging TCL scripting with Magic VLSI, designers can create parameterized device layouts, reducing manual layout time and ensuring design consistency.

## 🚀 Features

- Half-automated generation of basic devices (MOSFETs, resistors, capacitors)
- Parameterized layout generation (width, length, fingers, multipliers)
- DRC-clean layout generation
- Support for both NMOS and PMOS devices
- Configurable guard rings and substrate contacts
- Modular script architecture for easy extension

## 📋 Prerequisites

- [Magic VLSI](http://opencircuitdesign.com/magic/) layout tool
- [Sky130 PDK](https://github.com/google/skywater-pdk) installed and configured
- netgen for lvs
- Basic knowledge of TCL scripting and VLSI layout design

## 🚀 Usage

run bash script


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [SkyWater Technology](https://skywatertechnology.com/) for the open source PDK
- [OpenCircuitDesign](http://opencircuitdesign.com/) for Magic VLSI
- [Google](https://google.com) for supporting open source silicon initiatives
- The open source EDA community
- Deepseek

## Completed
- inverter

## 📊 TODO

- [ ] buffer,nand,nor,or,and,xor,xnor
