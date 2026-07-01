# ======================
# COLOR DEFINITIONS
# ======================

GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[1;34m
RED    := \033[0;31m
NC     := \033[0m

# ======================
#       SHORTCUTS
# ======================

all: delete add commit push status
sync: stash pull status

# ======================
#        COMMANDS
# ======================

delete:
	rm -rf ./src/dv/covReport ./src/dv/work 
	rm ./src/dv/wave.vcd ./src/dv/coverage.ucdb ./src/dv/waveform.wlf 
	rm ./src/dv/top.log ./src/dv/simulation.log
	#rm ./src/dv/vsim.wlf ./src/dv/vsim_stacktrace.vstf   
	#rm /transcript

add:
	@printf "$(BLUE)[ADD]$(NC) Adding files...\n"
	@git add -A || { printf "$(RED)[ERROR] add failed!$(NC)\n"; exit 1; }
	@printf "$(GREEN)[ADD]$(NC) Files added successfully.\n"

status:
	@printf "$(YELLOW)[STATUS]$(NC)\n"
	@git status || { printf "$(RED)[ERROR] status failed!$(NC)\n"; exit 1; }

commit:
	@printf "$(BLUE)[COMMIT]$(NC) Enter commit message: "
	@read msg; \
		printf "$(BLUE)[COMMIT]$(NC) Committing...\n"; \
		git commit -m "$$msg" || { printf "$(RED)[ERROR] commit failed!$(NC)\n"; exit 1; }; \
		printf "$(GREEN)[COMMIT]$(NC) Commit successful!\n"

push:
	@printf "$(BLUE)[PUSH]$(NC) Pushing to remote...\n"
	@git push origin main || { printf "$(RED)[ERROR] push failed!$(NC)\n"; exit 1; }
	@printf "$(GREEN)[PUSH]$(NC) Push successful!\n"

stash:
	@printf "$(BLUE)[STASH]$(NC) Stashing changes...\n"
	@git stash -u || { printf "$(RED)[ERROR] stash failed!$(NC)\n"; exit 1; }
	@printf "$(GREEN)[STASH]$(NC) Changes stashed.\n"

pull:
	@printf "$(BLUE)[PULL]$(NC) Pulling latest changes...\n"
	@git pull || { printf "$(RED)[ERROR] pull failed!$(NC)\n"; exit 1; }
	@printf "$(GREEN)[PULL]$(NC) Pull successful!\n"
