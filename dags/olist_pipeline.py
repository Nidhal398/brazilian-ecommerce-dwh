from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import subprocess
import os

default_args = {
    'owner': 'nidhal',
    'retries': 1,
    'retry_delay': timedelta(minutes=2)
}

TALEND_CONTEXT = [
    "--context_param", "DB_HOST=olist_postgres",
    "--context_param", f"DB_PORT=5432",
    "--context_param", "DB_NAME=SA",
    "--context_param", "DB_NAME_DW=olist_dw",
    "--context_param", "DB_USER=postgres",
    "--context_param", "DB_PASSWORD=nidhal"
]

TALEND_BASE = "/opt/talend/jobs/All_jobs"


def run_talend_job(job_name):
    job_script = os.path.join(TALEND_BASE, job_name, job_name, f"{job_name}_run.sh")

    if not os.path.exists(job_script):
        raise FileNotFoundError(f"Script introuvable : {job_script}")

    cmd = [job_script] + TALEND_CONTEXT

    print(f"Lancement : {job_name}")
    result = subprocess.run(cmd, capture_output=True, text=True)

    print(f"STDOUT:\n{result.stdout}")
    if result.stderr:
        print(f"STDERR:\n{result.stderr}")

    if result.returncode != 0:
        raise RuntimeError(f"Job '{job_name}' echoue (code: {result.returncode})")

    print(f"Job '{job_name}' termine avec succes")




# Staging Area
def run_sa_customers():    run_talend_job("Sa_Customers")
def run_sa_geolocation():  run_talend_job("Sa_geolocation")
def run_sa_items():        run_talend_job("Sa_items")
def run_sa_orders():       run_talend_job("Sa_orders")
def run_sa_payement():     run_talend_job("Sa_Payement")
def run_sa_product():      run_talend_job("Sa_product")
def run_sa_review():       run_talend_job("Sa_review")
def run_sa_sellers():      run_talend_job("Sa_sellers")
def run_sa_transaction():  run_talend_job("Sa_transaction")

# Data Warehouse
def run_dim_date():        run_talend_job("dim_date")
def run_dim_client():      run_talend_job("dim_client")
def run_dim_product():     run_talend_job("dim_product")
def run_dim_vendeur():     run_talend_job("dim_vendeur")
def run_fait_vente():      run_talend_job("fait_vente")
def push_to_github():
    token = os.environ.get("GITHUB_TOKEN")
    repo = os.environ.get("GITHUB_REPO")
    
    cmds = [
        "git config --global user.email 'airflow@olist.com'",
        "git config --global user.name 'Airflow Bot'",
        f"git -C /opt/airflow/dags remote set-url origin https://{token}@github.com/{repo}.git",
        "git -C /opt/airflow/dags add -A",
        "git -C /opt/airflow/dags commit -m 'Auto: Pipeline executed successfully' || true",
        "git -C /opt/airflow/dags push origin main || true"
    ]
    
    for cmd in cmds:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        print(f"STDOUT: {result.stdout}")
        if result.stderr:
            print(f"STDERR: {result.stderr}")

with DAG(
    dag_id='olist_pipeline',
    description='Olist E-Commerce ETL Pipeline — Talend + PostgreSQL + Airflow',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['olist', 'etl', 'datawarehouse', 'talend', 'v2']
) as dag:

    # Staging Area tasks
    t_sa_customers   = PythonOperator(task_id='Sa_Customers',   python_callable=run_sa_customers)
    t_sa_geolocation = PythonOperator(task_id='Sa_geolocation', python_callable=run_sa_geolocation)
    t_sa_items       = PythonOperator(task_id='Sa_items',       python_callable=run_sa_items)
    t_sa_orders      = PythonOperator(task_id='Sa_orders',      python_callable=run_sa_orders)
    t_sa_payement    = PythonOperator(task_id='Sa_Payement',    python_callable=run_sa_payement)
    t_sa_product     = PythonOperator(task_id='Sa_product',     python_callable=run_sa_product)
    t_sa_review      = PythonOperator(task_id='Sa_review',      python_callable=run_sa_review)
    t_sa_sellers     = PythonOperator(task_id='Sa_sellers',     python_callable=run_sa_sellers)
    t_sa_transaction = PythonOperator(task_id='Sa_transaction', python_callable=run_sa_transaction)

    # DWH tasks
    t_dim_date    = PythonOperator(task_id='dim_date',    python_callable=run_dim_date)
    t_dim_client  = PythonOperator(task_id='dim_client',  python_callable=run_dim_client)
    t_dim_product = PythonOperator(task_id='dim_product', python_callable=run_dim_product)
    t_dim_vendeur = PythonOperator(task_id='dim_vendeur', python_callable=run_dim_vendeur)
    t_fait_vente  = PythonOperator(task_id='fait_vente',  python_callable=run_fait_vente)

    # Staging en parallèle → DWH séquentiel
    [
        t_sa_customers,
        t_sa_geolocation,
        t_sa_items,
        t_sa_orders,
        t_sa_payement,
        t_sa_product,
        t_sa_review,
        t_sa_sellers,
        t_sa_transaction
    ] >> t_dim_date
    t_github_push = PythonOperator(
    task_id='push_to_github',
    python_callable=push_to_github
)



    t_dim_date >> t_dim_client >> t_dim_product >> t_dim_vendeur >> t_fait_vente>> t_github_push