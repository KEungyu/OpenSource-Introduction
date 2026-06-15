import pandas as pd

df = pd.read_csv('2019_kbo_for_kaggle_v2.csv')

def solve1():
    print("=== 1. Print the Top 10 players from 2015 to 2018 ===")
    metrics = ['H', 'avg', 'HR', 'OBP']

    for year in range(2015, 2019):
        print(f"\n{year} YEAR")
        df_year = df[df['year'] == year]

        for metric in metrics:
            df_top10 = df_year.sort_values(by=metric, ascending=False).head(10)
            top10_players = df_top10['batter_name'].tolist()

            print(f"\n {metric} Top 10: {top10_players}")
    
def solve2():
    print("\n=== 2. Print the player with the highest war by position in 2018 ===")
    df_2018 = df[df['year'] == 2018]

    best_war_idx = df_2018.groupby('cp')['war'].idxmax()
    best_players = df_2018.loc[best_war_idx, ['cp', 'batter_name', 'war']]

    print("\n[The players with the highest war by position]")
    print(best_players.to_string(index=False))

def solve3():
    print("\n=== 3. Print metric which has the highest correlation with salary ===\n")
    cols = ['R', 'H', 'HR', 'RBI', 'SB', 'war', 'avg', 'OBP', 'SLG', 'salary']

    corr_matrix = df[cols].corr()
    salary_corr = corr_matrix['salary'].drop('salary')

    corr_feature = salary_corr.abs().idxmax()
    corr_value = salary_corr[corr_feature]

    print("[Correlation]")
    print(salary_corr)
    print(f"\nThe metric which has the highest correlation with salary: {corr_feature} ({corr_value:.4f})")

solve1()
solve2()
solve3()