#!/bin/bash

# Script to start/stop networking bootcamp EC2 instances
# Usage: ./manage-instances.sh [start|stop|status]

set -e

# Configuration
PROJECT_TAG="networking-bootcamp"
REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get instance IDs by project tag
get_instance_ids() {
    aws ec2 describe-instances \
        --region "$REGION" \
        --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' \
        --output text
}

# Function to get instance IDs only
get_instance_ids_only() {
    aws ec2 describe-instances \
        --region "$REGION" \
        --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text
}

# Function to start instances
start_instances() {
    print_status "Starting networking bootcamp instances..."
    
    INSTANCE_IDS=$(get_instance_ids_only)
    
    if [ -z "$INSTANCE_IDS" ]; then
        print_warning "No instances found with project tag: $PROJECT_TAG"
        return 1
    fi
    
    print_status "Found instances: $INSTANCE_IDS"
    
    # Start instances
    aws ec2 start-instances \
        --region "$REGION" \
        --instance-ids $INSTANCE_IDS
    
    print_success "Start command sent to instances"
    
    # Wait for instances to be running
    print_status "Waiting for instances to be in running state..."
    aws ec2 wait instance-running \
        --region "$REGION" \
        --instance-ids $INSTANCE_IDS
    
    print_success "All instances are now running!"
    show_status
}

# Function to stop instances
stop_instances() {
    print_status "Stopping networking bootcamp instances..."
    
    INSTANCE_IDS=$(get_instance_ids_only)
    
    if [ -z "$INSTANCE_IDS" ]; then
        print_warning "No instances found with project tag: $PROJECT_TAG"
        return 1
    fi
    
    print_status "Found instances: $INSTANCE_IDS"
    
    # Stop instances
    aws ec2 stop-instances \
        --region "$REGION" \
        --instance-ids $INSTANCE_IDS
    
    print_success "Stop command sent to instances"
    
    # Wait for instances to be stopped
    print_status "Waiting for instances to be in stopped state..."
    aws ec2 wait instance-stopped \
        --region "$REGION" \
        --instance-ids $INSTANCE_IDS
    
    print_success "All instances are now stopped!"
    show_status
}

# Function to show instance status
show_status() {
    print_status "Current status of networking bootcamp instances:"
    echo
    printf "%-20s %-35s %-15s %-15s\n" "INSTANCE-ID" "NAME" "STATE" "PUBLIC-IP"
    printf "%-20s %-35s %-15s %-15s\n" "------------" "----" "-----" "---------"
    
    get_instance_ids | while read -r instance_id name state; do
        # Get public IP if instance is running
        if [ "$state" = "running" ]; then
            public_ip=$(aws ec2 describe-instances \
                --region "$REGION" \
                --instance-ids "$instance_id" \
                --query 'Reservations[].Instances[].PublicIpAddress' \
                --output text)
            if [ "$public_ip" = "None" ] || [ -z "$public_ip" ]; then
                public_ip="N/A"
            fi
        else
            public_ip="N/A"
        fi
        
        # Color code the state and use echo instead of printf for colors
        case $state in
            "running")
                printf "%-20s %-35s ${GREEN}%-15s${NC} %-15s\n" "$instance_id" "$name" "$state" "$public_ip"
                ;;
            "stopped")
                printf "%-20s %-35s ${RED}%-15s${NC} %-15s\n" "$instance_id" "$name" "$state" "$public_ip"
                ;;
            "pending"|"stopping"|"starting")
                printf "%-20s %-35s ${YELLOW}%-15s${NC} %-15s\n" "$instance_id" "$name" "$state" "$public_ip"
                ;;
            *)
                printf "%-20s %-35s %-15s %-15s\n" "$instance_id" "$name" "$state" "$public_ip"
                ;;
        esac
    done
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [start|stop|status]"
    echo
    echo "Commands:"
    echo "  start   - Start all networking bootcamp instances"
    echo "  stop    - Stop all networking bootcamp instances"
    echo "  status  - Show current status of all instances"
    echo
    echo "This script manages EC2 instances tagged with Project=$PROJECT_TAG"
}

# Main script logic
case "${1:-}" in
    "start")
        start_instances
        ;;
    "stop")
        stop_instances
        ;;
    "status")
        show_status
        ;;
    "")
        print_error "No command specified"
        show_usage
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
