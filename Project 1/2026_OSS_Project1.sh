#! /bin/bash
if [ $# -ne 1 ]
then 
	echo "usage: $0 file"
	exit 1
fi

echo "***********OSS1 - Project1***********"
echo "*	StudentID : 12224414	*"
echo "*	Name     : Eungyu Kim	*"  
echo "*************************************"  

until [ "$choice" = "6" ]
do
	echo "[MENU]"
	echo "1. Search tracks by artist name and track name"
	echo "2. List top 5 tracks by popularity in a specific genre"
	echo "3. Show top 5 longest tracks by duration"
	echo "4. Merge duplicate tracks and combine genres"
	echo "5. Analyze tracks - count, avg danceability, energy, valence"
	echo "6. Quit"
	read -p "Enter your COMMAND (1~6): " choice

	case "$choice" in
	1)
		read -p "Enter an artist name to search: " artist
		read -p "Enter a track name to search: " track
		
		echo ""
		
		echo "Search results for \"$artist\" / \"$track\":"
		echo "artists track_name energy tempo"

		sed '1d' "$1" | tr -d '\r' | \
			awk -F '\t' -v art="$artist" -v tra="$track" 'BEGIN { 
			a = tolower(art); t = tolower(tra) }
			tolower($2) == a && tolower($4) == t { 
			printf "%s\t%s\t%s\t%s\n", $2, $4, $9, $18 
			}'
		echo ""
		;; 

	2)
		read -p "Enter a genre: " genre
		echo ""
		echo "Top 5 tracks by popularity in \"$genre\":"

 		sed '1d' "$1" | tr -d '\r' |	awk -F '\t' -v gen="$genre" '$20 == gen { 
			printf "%s\t%s\t%s\t%s\t%s\n", $2, $4, $5, $9, $17 }' | \
			sort -t $'\t' -k 3 -nr | head -n 5
		echo ""
		;;
	
	3)
		echo "Top 5 longest tracks by duration:"
		sed '1d' "$1" | tr -d '\r' | sort -t $'\t' -k2,2 -k4,4 -u | \
				sort -t $'\t' -k 6 -nr | head -n 5 | awk -F '\t' '{
				min = int($6 / 1000 / 60)
				sec = int(($6 / 1000) % 60)
				printf "%s\t%s\t%d:%02d\n", $2, $4, min, sec
			}' 
		echo ""
		;;	
	
	4) 
		echo ""
		echo "Tracks appearing in multiple genres (top 5 by popularity):"

		sed '1d' "$1" | tr -d '\r' | sort -t $'\t' -k2,2 -k4,4 | awk -F '\t' ' {
				if ($2 == prev_artist && $4 == prev_track) {
					if (index(genres, $20) == 0) {
						genres = genres "|" $20
						count++
					}
				}
			
				else {
					if (count >= 2) {
							printf "%d\t%s\t%s\t%s\n", prev_pop, prev_track, prev_artist, genres
					}

						prev_artist = $2
						prev_track = $4
						prev_pop = $5
						genres = $20
						count = 1
				}
			}
			
			END {
				if (count >= 2) {
					printf "%d\t%s\t%s\t%s\n", prev_pop, prev_track, prev_artist, genres
				}
			}' | sort -nr | head -n 5 | awk -F '\t' '{
					printf "%s\t%s\t%s\n", $3, $2, $4
					}'
			echo ""
			;;
	
	5)
		read -p "Enter minimum popularity threshold: " threshold
		echo ""

		sed '1d' "$1" | tr -d '\r' | sort -t $'\t' -k2,2 -k4,4 -u | \
			awk -F '\t' -v th="$threshold" ' { 
				prev_a = $2
				prev_t = $4

				if ($5 >= th) {
					count++
					sum_dance += $8
					sum_energy += $9
					sum_valence += $17
				}
			}

			END { 
				printf "popularity >= %d tracks: %d\n", th, count

				if (count > 0) {
					printf "avg danceability: %.2f\n", sum_dance / count
					printf "avg energy: %.2f\n", sum_energy / count
					printf "avg valence: %.2f\n", sum_valence / count 
				}
			}'
		echo ""
		;;

	6)
		echo "Bye!"
		echo ""
		;;
	esac
done
