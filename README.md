# geotechnical-simulations-with-moose

> [!NOTE]  
> This document is still at an early stage of development. 
> Some parts already have text, others exist as bullet 
> points and the rest are just placeholders. 

The open-source, parallel finite element framework Moose 
([mooseframework.inl.gov](https://mooseframework.inl.gov)) 
can also be used to perform geotechnical simulations. This 
document aims to collect options and techniques that are 
suitable for creating such geotechnical simulations with 
Moose. Main focus are quasi-static simulations.

This whitepaper collects information and code for 
geotechnical simulations with the software Moose. This 
document is primarily intended as a collection of information 
rather than a textbook or step-by-step guide. As such, it 
is intended to be a ’living’ document that will be continually 
edited and updated.

> [!IMPORTANT]  
> This document is published under the 
> [CC-BY-SA-4.0 license](https://creativecommons.org/licenses/by-sa/4.0/).
> No warranties are given.

## Compiling the PDF

The document is provided as TeX source and compiled PDF. 
For compiling [TeX Live 2024](https://www.tug.org/texlive/) is 
used. Source code formatting is done via [latexindent](https://github.com/cmhughes/latexindent.pl) and the corresponding setting files (`.latexindent.yaml`) are included in this repository.