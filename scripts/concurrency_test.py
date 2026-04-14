# This script begins a concurrent load test on the target server.
# The values for CONCURRENT_USERS and TEST_DURATION_SECONDS determines the load of this test.
# Typically run through a SSH Tunnel to the target environment.
import oracledb
import concurrent.futures
import random
import time
import statistics

# --- Configuration ---
DB_USER = "sys"
DB_PASS = "COSC2024"
DB_DSN = "localhost:1521/orclpdb.localdomain"
CONCURRENT_USERS = 50     # Number of users for this test, increase or decrease this value.
TEST_DURATION_SECONDS = 900 # Duration of test, increase or decrease this value.

# --- Real docid values from the data to use ---
VALID_DOCIDS = ['100797', '100798', '100799', '10080', '100800', '100801', '100802',
                '100803', '100804', '100805', '100806', '100807', '100808', '100809',
                '10081', '100810', '100811', '100812', '100813', '100814', '100815',
                '100816', '100817', '100818', '100819', '10082', '100820', '100821',
                '100822', '100823', '100824', '100825', '100826', '100828', '100829',
                '10083', '100830', '100831', '100832', '100833', '100834', '100835',
                '100836', '100837', '100838', '100839', '10084', '100840', '100841', '100842']

# --- The Query Arsenal ---
QUERIES = {
    # OLTP: 70% of Traffic
    "Q1_Article_Fetch": "SELECT ra.docid, ra.title_1, ra.publish_year, aa.abstract_length FROM hal.research_articles ra LEFT JOIN hal.article_abstracts aa ON aa.docid = ra.docid WHERE ra.docid = :docid",
    "Q2_Author_List": "SELECT au.author_name FROM hal.article_authors au WHERE au.docid = :docid ORDER BY au.author_name",
    "Q3_Keyword_Tags": "SELECT k.keyword FROM hal.article_keywords k WHERE k.docid = :docid",

    # Light OLAP: 20% of Traffic
    "Q4_Top_Collections": """
    SELECT coll_code, publish_year, article_count
    FROM hal.mv_q4_collections
    WHERE publish_year BETWEEN :start_year AND :end_year
    ORDER BY article_count DESC
    FETCH FIRST 10 ROWS ONLY
    """,

    # Heavy OLAP: 10% of Traffic
    "Q5_Broad_Domain": """
    SELECT domain_label, publish_year, unique_docs
    FROM hal.mv_q5_domains
    WHERE publish_year BETWEEN :start_year AND :end_year
    """,

    "Q6_Domain_Matrix": """
    SELECT k.keyword, COUNT(DISTINCT a.docid)
    FROM hal.research_articles a
    JOIN hal.article_keywords k ON a.docid = k.docid
    JOIN hal.article_domains_en d ON a.docid = d.docid
    WHERE d.domain_label = :domain_name
    AND a.publish_year = :target_year
    GROUP BY k.keyword
    ORDER BY 2 DESC FETCH FIRST 5 ROWS ONLY
    """
}

def user_session(user_id):
    """Simulates a user browsing the dashboard"""
    # Dictionary to hold the execution times for this specific thread
    timings = {k: [] for k in QUERIES.keys()}

    try:
        connection = oracledb.connect(
            user=DB_USER, password=DB_PASS, dsn=DB_DSN, mode=oracledb.AUTH_MODE_SYSDBA
        )
        cursor = connection.cursor()
        print(f"User {user_id} active.")

        end_time = time.time() + TEST_DURATION_SECONDS

        while time.time() < end_time:
            chance = random.random()

            # --- 70% OLTP Traffic (Fast Lookups) ---
            if chance < 0.70:
                q_name = random.choice(["Q1_Article_Fetch", "Q2_Author_List", "Q3_Keyword_Tags"])
                # Guessing valid range based on real DocIDs
                docid = random.choice(VALID_DOCIDS)

                start_q = time.time()
                cursor.execute(QUERIES[q_name], docid=docid)
                cursor.fetchall()
                timings[q_name].append(time.time() - start_q)

            # --- 20% Light OLAP Traffic ---
            elif chance < 0.90:
                q_name = "Q4_Top_Collections"
                start_yr = random.randint(1997, 2004)
                end_yr = start_yr + 5

                start_q = time.time()
                cursor.execute(QUERIES[q_name], start_year=start_yr, end_year=end_yr)
                cursor.fetchall()
                timings[q_name].append(time.time() - start_q)

            # --- 10% Heavy OLAP Traffic ---
            else:
                q_name = random.choice(["Q5_Broad_Domain", "Q6_Domain_Matrix"])

                if q_name == "Q5_Broad_Domain":
                    start_yr = random.randint(1997, 2004)
                    end_yr = start_yr + 5
                    start_q = time.time()
                    cursor.execute(QUERIES[q_name], start_year=start_yr, end_year=end_yr)
                else: # Q6
                    # Real values for (Domain, Keyword, Year)
                    heavy_hitters = [
                        ('shs.edu_FacetSep_Humanities and Social Sciences/Education', 'Education -- Data processing', 2004),
                        ('shs.scipo_FacetSep_Humanities and Social Sciences/Political science', 'France', 2007),
                        ('shs.socio_FacetSep_Humanities and Social Sciences/Sociology', 'Sociologie', 2007)
                    ]
                    target = random.choice(heavy_hitters)

                    start_q = time.time()
                    cursor.execute(QUERIES[q_name], domain_name=target[0], target_year=target[2])

                cursor.fetchall()
                timings[q_name].append(time.time() - start_q)

            time.sleep(0.5) # Slow down a bit

    except Exception as e:
        print(f"User {user_id} crashed: {e}")
    finally:
        try:
            cursor.close()
            connection.close()
        except:
            pass

    return timings

# --- The work being done ---
print(f"Launching {CONCURRENT_USERS} users for {TEST_DURATION_SECONDS} seconds...")
start_time = time.time()

master_timings = {k: [] for k in QUERIES.keys()}

with concurrent.futures.ThreadPoolExecutor(max_workers=CONCURRENT_USERS) as executor:
    futures = [executor.submit(user_session, i) for i in range(CONCURRENT_USERS)]

    for future in concurrent.futures.as_completed(futures):
        result = future.result()
        if result:
            for q_name in master_timings.keys():
                master_timings[q_name].extend(result[q_name])

print(f"\n--- TEST COMPLETE in {round(time.time() - start_time, 2)}s ---")

# --- Granular Telemetry Report ---
print("\n=== CLIENT-SIDE PERFORMANCE SUMMARY ===")
for q_name, times in master_timings.items():
    if times:
        print(f"\n{q_name} (Executions: {len(times)})")
        print(f"  - Average: {round(statistics.mean(times), 4)}s")
        print(f"  - Max:     {round(max(times), 4)}s")
    else:
        print(f"\n{q_name}: 0 Executions")

