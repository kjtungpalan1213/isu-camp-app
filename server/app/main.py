from fastapi import FastAPI
from app.database.supabase import supabase
from app.routes.auth import router as auth_router
from app.routes.login import router as login_router

app = FastAPI(title="ISU-CAMP Backend")

app.include_router(auth_router)
app.include_router(login_router)


@app.get("/")
def root():
    return {"message": "ISU-CAMP Backend is running"}


@app.get("/test-supabase")
def test_supabase():
    try:
        response = supabase.table("building").select("*").limit(5).execute()

        return {
            "success": True,
            "data": response.data
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }