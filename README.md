# Plant3D

Dette repository indeholder en samling AutoLISP-scripts til brug i AutoCAD Plant 3D. Nedenfor findes en kort beskrivelse af hver fil.

## Oversigt over Lisp-filer

- **AutoLoad.lsp**
  Loader de øvrige scripts fra brugerens `Lisp Library` mappe ved opstart.
  Gør det nemt at have alle funktioner tilgængelige automatisk.

- **BatchAttributeEditorV1-5.lsp**
  Redigerer attributter i mange blokke og tegninger via et dialogvindue.
  Programmet kan også udtrække attributter til lister for videre bearbejdning.

- **CreateLayer.lsp**
  Opretter et sæt lag hvis de ikke allerede findes i tegningen.
  Understøtter både standardfarver og true color værdier.

- **InsertRevit.lsp**
  Indsætter en Revit-tegning som XREF med position og rotation fra en XML-fil.
  XML-filen læses direkte uden brugerinteraktion for en hurtig arbejdsgang.

- **InsertRevitxref.lsp**
  Ligner `InsertRevit.lsp`, men spørger efter sti til `Import.xml` og gemmer valget.
  På den måde kan samme XML benyttes igen uden at vælge filen hver gang.

- **MacAttV3-1.lsp**
  Et avanceret værktøj til global redigering og udtræk af blokattributter.
  Kan gemme data i Excel-format og understøtter flere forskellige arbejdsmetoder.

- **MoveToInsertRevitCordinate.lsp**
  Flytter blokke til koordinater angivet i `Import.xml` og roterer dem korrekt.
  Gemmer også stien til XML-filen så den kan genbruges.

- **MoveToPlantCordinate.lsp**
  Samme funktionalitet som ovenstående men uden søgning efter "Plant 3D Models".
  Henter koordinater fra `Import.xml` og placerer alle blokreferencer derefter.

- **MoveToRevitCordinate.lsp**
  Læser `Export`-sektionen i XML-filen og flytter blokke til de angivne mål.
  Bruges typisk ved eksport til Revit for at nulstille koordinater.

- **countblocks.lsp**
  Optæller alle blokdefinitioner i den åbne tegning og viser resultatet.
  Udskriften sorteres efter antal så de mest brugte blokke vises øverst.

- **test.lsp**
  En testversion af indsættelse af Revit-XREF med ekstra debug-udskrifter.
  Anvendes til fejlfinding og udvikling før endelig implementering.

- **ValveCodeSelector.lsp**
  Værktøj til at hente ventilkoder fra en SQLite-database og knytte dem til en valgt Plant 3D-asset.
