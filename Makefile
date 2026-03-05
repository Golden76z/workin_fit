.PHONY: help run build clean test emulator arb_gen

# Colors for output (using tput for better compatibility)
GREEN := $(shell tput setaf 2 2>/dev/null || echo "")
YELLOW := $(shell tput setaf 3 2>/dev/null || echo "")
RED := $(shell tput setaf 1 2>/dev/null || echo "")
BLUE := $(shell tput setaf 4 2>/dev/null || echo "")
BOLD := $(shell tput bold 2>/dev/null || echo "")
NC := $(shell tput sgr0 2>/dev/null || echo "") # No Color

.DEFAULT_GOAL := help

help: ## Show this help message
	@printf "$(BOLD)$(GREEN)Flutter Development Commands$(NC)\n"
	@printf "\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BOLD)$(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@printf "\n"

run: ## Run the Flutter app
	@printf "$(GREEN)🚀 Running Flutter app...$(NC)\n"
	flutter run

build: ## Build APK for Android
	@printf "$(GREEN)🔨 Building Android APK...$(NC)\n"
	flutter build apk
	@printf "$(GREEN)✅ Build complete$(NC)\n"

clean: ## Clean Flutter build files
	@printf "$(YELLOW)🧹 Cleaning Flutter build files...$(NC)\n"
	flutter clean
	@printf "$(GREEN)✅ Clean complete$(NC)\n"

test: ## Run Flutter tests
	@printf "$(GREEN)🧪 Running Flutter tests...$(NC)\n"
	flutter test
	@printf "$(GREEN)✅ Tests complete$(NC)\n"

emulator: ## Start Android Emulator (Pixel_5_API_34)
	@printf "$(GREEN)📱 Starting Android Emulator...$(NC)\n"
	emulator @Pixel_5_API_34
	@printf "$(GREEN)✅ Emulator starting$(NC)\n"

arb_gen: ## Re-generate localization files from ARB files
	@printf "$(GREEN)🌐 Generating localization files...$(NC)\n"
	flutter gen-l10n
	@printf "$(GREEN)✅ Localization files generated$(NC)\n"

icons: ## Generate app launcher icons from assets/icons/app_icon.png
	@printf "$(GREEN)🖼  Generating launcher icons...$(NC)\n"
	flutter pub get && flutter pub run flutter_launcher_icons
	@printf "$(GREEN)✅ Launcher icons generated$(NC)\n"

splash: ## Generate native splash screens from assets/images/splash_logo.png
	@printf "$(GREEN)🖼  Generating splash screens...$(NC)\n"
	flutter pub get && flutter pub run flutter_native_splash:create
	@printf "$(GREEN)✅ Splash screens generated$(NC)\n"
