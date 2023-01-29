Skrypt pobiera tytuł i cenę z kolejnych stron, 
zapisuje i odwiedza te linki, które nie wymagaja kliknięcia (te z kliknięciem z samym getem wywołują BLOCKED),
w odwiedzonych plikach zbiera parametry
i zapisuje do bazy danych przez Sequel


Zamiast get z net/http użyłem Selenium, ponieważ strona zwracała 403 i domagała się włączenia JS i wyłączenia adblock. Użyłem selenium tylko do pobierania samego sourca i na nim działa Nokogiri. Wchodzenie w linki przez get w Selenium zamiast kliknięcia, żeby udawać zwykły get.

Skrypt uruchamia się z lini komend z podaniem linku wejściowej strony wybranej kategorii i opcjonalnie podania słowa kluczowego

ruby crawl.rb [link] [keyword]

Przykładowe uruchomienie:

ruby crawl.rb https://allegro.pl/kategoria/trening-fitness-rowery-treningowe-110140?order=qd kettler

Przed uruchomieniem trzeba stworzyć bazę danych crawled i uruchomić skrypt db.rb który utworzy tabelę.