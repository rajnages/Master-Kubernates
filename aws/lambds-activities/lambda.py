import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # Step 1: Delete Unused (Available) EBS Volumes
    print("Checking for unused EBS volumes...")
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    
    for volume in volumes['Volumes']:
        volume_id = volume['VolumeId']
        try:
            ec2.delete_volume(VolumeId=volume_id)
            print(f"Deleted unused EBS volume: {volume_id}")
        except Exception as e:
            print(f"Could not delete volume {volume_id}. Error: {e}")
    
    # Step 2: Identify and Delete Orphaned Snapshots
    print("Checking for orphaned snapshots...")
    # List all snapshots owned by this account
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])
    all_volume_ids = {volume['VolumeId'] for volume in ec2.describe_volumes()['Volumes']}
    
    for snapshot in snapshots['Snapshots']:
        snapshot_id = snapshot['SnapshotId']
        associated_volume_id = snapshot.get('VolumeId', None)
        
        # If the snapshot's volume is not in the active volume list, delete it
        if associated_volume_id not in all_volume_ids:
            try:
                ec2.delete_snapshot(SnapshotId=snapshot_id)
                print(f"Deleted orphaned snapshot: {snapshot_id}")
            except Exception as e:
                print(f"Could not delete snapshot {snapshot_id}. Error: {e}")
