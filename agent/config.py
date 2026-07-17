"""Env-driven configuration (pydantic-settings).

ANTHROPIC_API_KEY, AMEEN_MODEL, REDIS_URL, DATABASE_URL, AMEEN_MOCK, ...
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    anthropic_api_key: str = ""
    openrouter_api_key: str = ""
    ameen_provider: str = "anthropic"  # anthropic | openrouter | mock
    ameen_model: str = "claude-sonnet-5"
    redis_url: str = "redis://localhost:6379/0"
    database_url: str = ""  # e.g. postgresql://user:pass@localhost:5432/ameen
    ameen_mock: bool = False  # AMEEN_MOCK=1 -> mock LLM + in-memory stores

    max_steps: int = 6                      # tool-use loop cap per turn
    history_token_budget: int = 12_000      # input tokens for history (est. 4 chars/token)
    verbatim_turns: int = 20                # most recent turns never compressed
    tool_result_max_bytes: int = 2_048      # per tool_result cap
    rate_limit_per_min: int = 10
    session_ttl_seconds: int = 86_400       # 24h (PDPL: no persistence beyond this)
    max_inflight_llm: int = 50              # backpressure semaphore


@lru_cache
def get_settings() -> Settings:
    return Settings()
