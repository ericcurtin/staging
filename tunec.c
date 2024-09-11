#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>      // For sleep
#include <dirent.h>      // For directory operations
#include <fcntl.h>       // For file control
#include <errno.h>
#include <ctype.h>

#define BUFFER_SIZE 128
#define CPU_PATH "/sys/devices/system/cpu/"  // Base path for CPU directories

// Function to read CPU utilization
double getCPUUtilization() {
    FILE *fp;
    char buffer[BUFFER_SIZE];
    unsigned long user, nice, system, idle;

    fp = fopen("/proc/stat", "r");
    if (fp == NULL) {
        perror("Error opening /proc/stat");
        return -1;
    }

    fgets(buffer, BUFFER_SIZE, fp);
    fclose(fp);

    sscanf(buffer, "cpu %lu %lu %lu %lu", &user, &nice, &system, &idle);
    return 100.0 * (user + nice + system) / (user + nice + system + idle);
}

// Function to read memory utilization
double getMemoryUtilization() {
    FILE *fp;
    char buffer[BUFFER_SIZE];
    unsigned long total, free;

    fp = fopen("/proc/meminfo", "r");
    if (fp == NULL) {
        perror("Error opening /proc/meminfo");
        return -1;
    }

    fgets(buffer, BUFFER_SIZE, fp); // Read the total memory line
    sscanf(buffer, "MemTotal: %lu kB", &total);

    fgets(buffer, BUFFER_SIZE, fp); // Read the free memory line
    sscanf(buffer, "MemFree: %lu kB", &free);

    fclose(fp);

    return 100.0 * (1 - (double)free / total);
}

// Function to write a value to a file
int writeToFile(const char *path, const char *value) {
    FILE *fp = fopen(path, "w");
    if (fp == NULL) {
        perror("Error opening file");
        return -1;
    }

    fprintf(fp, "%s", value);
    fclose(fp);
    return 0;
}

// Function to apply the governor to all CPUs
void applyGovernorToAllCPUs(const char *governor) {
    DIR *dir;
    struct dirent *entry;
    char path[BUFFER_SIZE];

    // Open the base CPU directory
    dir = opendir(CPU_PATH);
    if (dir == NULL) {
        perror("Error opening CPU directory");
        return;
    }

    // Iterate through all entries in the directory
    while ((entry = readdir(dir)) != NULL) {
        // Check if the entry is a CPU directory (starts with "cpu" and is followed by a number)
        if (strncmp(entry->d_name, "cpu", 3) == 0 && isdigit(entry->d_name[3])) {
            snprintf(path, BUFFER_SIZE, "%s%s/cpufreq/scaling_governor", CPU_PATH, entry->d_name);
            if (writeToFile(path, governor) != 0) {
                printf("Failed to set governor for %s.\n", entry->d_name);
            }
        }
    }

    closedir(dir);
}

// Function to apply a high-performance profile
void applyHighPerformanceProfile() {
    printf("Applying High Performance Profile...\n");
    applyGovernorToAllCPUs("performance");

    if (writeToFile("/proc/sys/vm/swappiness", "0") != 0) {
        printf("Failed to set swappiness to 0.\n");
    }

    // Add more system tweaks here
}

// Function to apply a power-saving profile
void applyPowerSavingProfile() {
    printf("Applying Power Saving Profile...\n");
    applyGovernorToAllCPUs("powersave");

    if (writeToFile("/proc/sys/vm/swappiness", "60") != 0) {
        printf("Failed to set swappiness to 60.\n");
    }

    // Add more system tweaks here
}

int main() {
    char profile[20];

    printf("System Tuning Tool - C Version\n");
    printf("Enter profile (high-performance / power-saving): ");
    scanf("%19s", profile);

    if (strcmp(profile, "high-performance") == 0) {
        applyHighPerformanceProfile();
    } else if (strcmp(profile, "power-saving") == 0) {
        applyPowerSavingProfile();
    } else {
        printf("Invalid profile. Please enter 'high-performance' or 'power-saving'.\n");
        return 1;
    }

    // Monitoring loop
    while (1) {
        double cpuUsage = getCPUUtilization();
        double memUsage = getMemoryUtilization();

        if (cpuUsage < 0 || memUsage < 0) {
            printf("Error reading system metrics.\n");
            break;
        }

        printf("CPU Usage: %.2f%%, Memory Usage: %.2f%%\n", cpuUsage, memUsage);

        // Adjust sleep duration as needed
        sleep(5);
    }

    return 0;
}

