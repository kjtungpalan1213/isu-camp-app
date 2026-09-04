from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from pwdlib import PasswordHash

from app.database.supabase import supabase


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

password_hash = PasswordHash.recommended()


# ==========================================
# LOGIN
# ==========================================

class LoginRequest(BaseModel):
    identifier: str
    password: str


@router.post("/login")
def login(data: LoginRequest):

    identifier = data.identifier.strip()

    # ======================================
    # LOGIN USING EMAIL
    # ======================================

    if "@" in identifier:

        result = (
            supabase
            .table("userInfo")
            .select("id, email, password")
            .eq("email", identifier)
            .execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=401,
                detail="Invalid username/email or password."
            )

        user_info = result.data[0]

    # ======================================
    # LOGIN USING USERNAME
    # ======================================

    else:

        user_result = (
            supabase
            .table("user")
            .select("id, username, info_id")
            .eq("username", identifier)
            .execute()
        )

        if not user_result.data:
            raise HTTPException(
                status_code=401,
                detail="Invalid username/email or password."
            )

        user = user_result.data[0]

        user_info_result = (
            supabase
            .table("userInfo")
            .select("id, email, password")
            .eq("id", user["info_id"])
            .execute()
        )

        if not user_info_result.data:
            raise HTTPException(
                status_code=401,
                detail="Invalid username/email or password."
            )

        user_info = user_info_result.data[0]

    # ======================================
    # VERIFY PASSWORD
    # ======================================

    try:
        password_valid = password_hash.verify(
            data.password,
            user_info["password"]
        )
    except Exception:
        password_valid = False

    if not password_valid:
        raise HTTPException(
            status_code=401,
            detail="Invalid username/email or password."
        )

    # ======================================
    # GET USER
    # ======================================

    user_result = (
        supabase
        .table("user")
        .select("id, username, info_id")
        .eq("info_id", user_info["id"])
        .execute()
    )

    if not user_result.data:
        raise HTTPException(
            status_code=404,
            detail="User account not found."
        )

    user = user_result.data[0]

    # ======================================
    # SUCCESS
    # ======================================

    return {
        "success": True,
        "message": "Login successful.",
        "user": {
            "id": user["id"],
            "username": user["username"],
            "email": user_info["email"]
        }
    }