# Automatically Delete Unused EBS Volumes and Snapshots
import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize the EC2 client
ec2_client = boto3.client('ec2')

def delete_unused_volumes():
    # Find and delete unused EBS volumes.
    logger.info("Checking for unused EBS volumes...")
    # Get all volumes
    volumes = ec2_client.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])['Volumes']
    
    for volume in volumes:
        volume_id = volume['VolumeId']
        logger.info(f"Deleting unused EBS volume: {volume_id}")
        try:
            ec2_client.delete_volume(VolumeId=volume_id)
            logger.info(f"Successfully deleted volume: {volume_id}")
        except Exception as e:
            logger.error(f"Failed to delete volume {volume_id}: {e}")

def delete_unused_snapshots():
    # Find and delete unused snapshots.
    logger.info("Checking for unused snapshots...")
    # Get all snapshots owned by the account
    snapshots = ec2_client.describe_snapshots(OwnerIds=['self'])['Snapshots']
    
    for snapshot in snapshots:
        snapshot_id = snapshot['SnapshotId']
        try:
            # Check if snapshot is in use (not attached to any volume)
            in_use = ec2_client.describe_volumes(Filters=[
                {'Name': 'snapshot-id', 'Values': [snapshot_id]}
            ])['Volumes']
            
            if not in_use:
                logger.info(f"Deleting unused snapshot: {snapshot_id}")
                ec2_client.delete_snapshot(SnapshotId=snapshot_id)
                logger.info(f"Successfully deleted snapshot: {snapshot_id}")
            else:
                logger.info(f"Snapshot {snapshot_id} is in use, skipping.")
        except Exception as e:
            logger.error(f"Failed to delete snapshot {snapshot_id}: {e}")

def lambda_handler(event, context):
    # Lambda function handler.
    logger.info("Started cleaning up unused EBS volumes and snapshots.")
    
    # Delete unused EBS volumes
    delete_unused_volumes()
    
    # Delete unused snapshots
    delete_unused_snapshots()
    
    logger.info("Cleanup process completed.")
