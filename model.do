* ------ Wczytanie i przekształcenie danych ------ *

xtset num rok 

* Uzyskanie podstawowych informacje o naszym panelu
xtdescribe

* Nasze dane dotyczą spółek giełdowych, które charakteryzują się dużą ilością obserwacji odstających.
* Sprawdzam rozkład ROA, ROE, tangibility, growth_sales, growth_assets, leverage_debt, leverage_liabilities - są to zmienne, które najprawdopodobniej zawierają obserwacje odstające.
* Reszta zmiennych jest zerojedynkowa, przyjmuje wartości z przedziału 0-1 lub została wcześniej zlogarytmowana.
graph box roa
graph box roe
graph box growth_assets
graph box growth_sales
graph box leverage_debt
graph box leverage_liabilities
* Widzimy, że rzeczywiście mamy dużo obserwacji odstających. W celu zminimalizowania ich wpływu na model użyjemy winsoryzacji.

* Biblioteki potrzebne do winsoryzacji
ssc install winsor

* Winsoryzujemy powyższe zmienne. 
* Na podstawie analizy histogramów dla każdej zmiennej zwinsoryzowanej na poziomie 1%, 2.5%, 5% i 10% określiłyśmy optymalne poziomy winsoryzacji.
winsor ROA, p(.025) gen(ROA_w025)
histogram ROA_w025
winsor ROE, p(.025) gen(ROE_w025)
histogram ROE_w025
winsor growth_sales, p(.05) gen(growth_sales_w05)
histogram growth_sales_w05
winsor growth_assets, p(.01) gen(growth_assets_w01)
histogram growth_assets_w01
winsor leverage_debt, p(0.05) gen(leverage_debt_w05)
histogram leverage_debt_w05
winsor leverage_liabilities, p(0.025) gen(leverage_liabilities_w025)
histogram leverage_liabilities_w025
**#

* ------ Estymator efektów stałych ------ *

* ROA

* Estymator efektów stałych - opcja fixed effects (fe) - od ogółu do szczegółu
xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_CEO leverage_liabilities_w025 sector_services_others sector_industrial dividend, fe
* Widzimy, że sector_services_others, sector_industrial i dividend są współliniowe, dlatego pomijamy je w kolejnych krokach.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_CEO leverage_liabilities_w025, fe
* Zmienna women_CEO ma p-value 0.23 - nieistotna statycznie. Spróbujmy wyestymować ten sam model ze zmienną women_vice_CEO.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_vice_CEO leverage_liabilities_w025, fe
* Zmienna women_vice_CEO również jest nieistotna statystycznie.
* Usuwamy zmienną zwiazaną z płcią prezesa z modelu. 

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 leverage_liabilities_w025, fe
* Widzimy, że wiek jest nieistotny statycznie. Literatura sugeruje jednak, że zależność pomiędzy ROA/ROE a wiekiem może być nieliniowa.

* Dodajmy zatem wiek^2 do modelu i oszacujmy taki model. 
gen age2 = age^2
xtreg ROA_w025 size_assets age age2 tangibility growth_sales_w05 leverage_liabilities_w025, fe
* Zmienna wiek jest istotna, jednak wiek^2 jest nieistotny. Stała stała się również nieistotna. Usuwamy zmienną wiek z modelu. 

xtreg ROA_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025, fe
* Otrzymujemy dobry model, wszystkie zmienne są łącznie istotne statycznie i każda osobno również.

* Zachowujemy oszacowania powyższego modelu
estimates store fe_roa

* Uzyskujemy oszacowanie wektora efektów indywidualnych u_i
predict efekty_fe_roa, u


* ROE

* ROE jest alternatywną zmienną mogącą mierzyć wyniki spółki. 
xtreg ROE_w025 size_assets age tangibility growth_sales_w05 women_ceo leverage_liabilities_w025 sector_services_others sector_industrial dividend, fe
* Widzimy, że sector_services_others, sector_industrial i dividend są współliniowe, dlatego pomijamy je w kolejnych krokach.

xtreg ROE_w025 size_assets age tangibility growth_sales_w05 women_ceo leverage_liabilities_w025, fe
* Otrzymujemy podobny wynik - zmienne women_CEO i age są nieistotne. Spróbujmy zastąpić zmienną women_CEO zmienną women_vice_CEO.

xtreg ROE_w025 size_assets age tangibility growth_sales_w05 women_vice_ceo leverage_liabilities_w025, fe
* Zmienna women_vice_CEO jest istotna stastystycznie(!) na poziomie p-value = 0.05. Usuwamy nieistotną zmienną age. 

xtreg ROE_w025 size_assets tangibility growth_sales_w05 women_vice_CEO leverage_liabilities_w025, fe
* Otrzymujemy dobry model, wszystkie zmienne są łącznie istotne statycznie (na poziomie p-value = 0.05) i każda osobno również.

* Zachowujemy oszacowania powyższego modelu
estimates store fe_roe

* Uzyskujemy oszacowanie wektora efektów indywidualnych u_i
predict efekty_fe_roe, u


* ------ Estymator efektów losowych ------ *

* ROA

* Estymator efektów losowych - opcja random effects (re) - od ogółu do szczegółu
xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_CEO leverage_liabilities_w025 sector_services_others sector_industrial dividend, re
* Zmienna sector_industrial ma największe p-value, zatem usuwamy ją z modelu.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_CEO leverage_liabilities_w025 sector_services_others dividend, re
* W kolejnym kroku zmienną o najwyższym p-value jest women_CEO - nieistotna statystycznie. Spróbujmy wyestymować ten sam model ze zmienną women_vice_CEO.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_vice_CEO leverage_liabilities_w025 sector_services_others dividend sector_industrial, re
* Usuwamy zmienną o najwyższym p-value - sector_services_others.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 women_vice_ceo leverage_liabilities_w025  dividend, re
* Zmienna women_vice_CEO również jest nieistotna statystycznie, zatem w tym modelu również usuwamy zmienną zwiazaną z płcią prezesa z modelu.

xtreg ROA_w025 size_assets age tangibility growth_sales_w05 leverage_liabilities_w025  dividend, re

xtreg ROA_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025, re

* Zachowujemy oszacowania powyższego modelu
estimates store re_roa

* Uzyskujemy oszacowanie wektora efektów indywidualnych u_i
predict efekty_re_roa, u


* ROE

xtreg ROE_w025 size_assets age tangibility growth_sales_w05 women_CEO leverage_liabilities_w025 sector_services_others sector_industrial dividend, re
* Usuwamy zmienną o najwyższym p-value, czyli age.

xtreg ROE_w025 size_assets tangibility growth_sales_w05 women_ceo leverage_liabilities_w025 sector_services_others sector_industrial dividend, re
* Otrzymujemy podobny wynik - zmienna women_CEO jest nieistotne. Spróbujmy zastąpić zmienną women_CEO zmienną women_vice_CEO.

xtreg ROE_w025 size_assets tangibility growth_sales_w05 women_vice_ceo leverage_liabilities_w025 sector_services_others sector_industrial dividend, re
* Zmienna women_vice_CEO jest również nieistotna statystycznie na poziomie istotności 5%. Usuwamy ją zatem z modelu.

xtreg ROE_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025 sector_services_others sector_industrial dividend, re
* Usuwamy zmienną o najwyższym p-value - sector_industrial.

xtreg ROE_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025 sector_industrial dividend, re
* Usuwamy kolejną zmienną o najwyższym p-value - sector_services_others.

xtreg ROE_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025 dividend, re
* Otrzymujemy dobry model, wszystkie zmienne są łącznie istotne statycznie (na poziomie p-value = 0.05) i każda osobno również.

* Zachowujemy oszacowania powyższego modelu
estimates store re_roe

* Uzyskujemy oszacowanie wektora efektów indywidualnych u_i
predict efekty_re_roe, u



* ------ Testy statystyczne ------ *

* ROA

* Test Breuscha-Pagana
xtreg ROA_w025 size_assets age2 tangibility growth_sales_w05 leverage_liabilities_w025  dividend, re
xttest0
* Na poziomie istotności 5% odrzucamy H0, że wariancja efektu indywidualnego jest zerowa, zatem mamy efekty indywidualne w modelu efektów losowych dla ROA.

* Test Hausmana
hausman fe_roa re_roa
* Na poziomie istotności 5% odrzucamy H0, zatem estymatory różnią się statystycznie. Estymator efektów losowych nie jest zgodny, zatem zastosujemy estymator efektów stałych.


* ROE

* Test Breuscha-Pagana
xtreg ROE_w025 size_assets tangibility growth_sales_w05 leverage_liabilities_w025 dividend, re
xttest0
* Na poziomie istotności 5% odrzucamy H0, że wariancja efektu indywidualnego jest zerowa, zatem mamy efekty indywidualne w modelu efektów losowych dla ROE.

* Test Hausmana
hausman fe_roe re_roe
* Na poziomie istotności 5% odrzucamy H0, zatem estymatory różnią się statystycznie. Estymator efektów losowych nie jest zgodny, zatem zastosujemy estymator efektów stałych.

* ------ Porównanie estymatorów efektów stałych i losowych ------ *

* ROA

twoway (scatter efekty_fe_roa efekty_re_roa num, subtitle("Porównanie efektów indywidualnych z modelu efektów stałych i losowych") legend(label(1 model efektów stałych) label(2 model efektów losowych)) xtitle("jednostki (identyfikatory) ") ytitle("efekty indywidualne"))

* ROE

twoway (scatter efekty_fe_roe efekty_re_roe num, subtitle("Porównanie efektów indywidualnych z modelu efektów stałych i losowych") legend(label(1 model efektów stałych) label(2 model efektów losowych)) xtitle("jednostki (identyfikatory) ") ytitle("efekty indywidualne"))




