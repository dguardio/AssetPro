# Asset Management System - User Training Manual
Version 1.0.0 | Last Updated: 2024-03-20

## Table of Contents
1. [Introduction](#1-introduction)
2. [Getting Started](#2-getting-started)
3. [Asset Management](#3-asset-management)
4. [Scanner Interface](#4-scanner-interface)
5. [Location Management](#5-location-management)
6. [Reports and Analytics](#6-reports-and-analytics)
7. [Troubleshooting](#7-troubleshooting)
8. [Best Practices](#8-best-practices)
9. [Security Guidelines](#9-security-guidelines)
10. [Maintenance](#10-maintenance)

## Related Documentation
- [API Documentation](/api/docs)
- [RFID Hardware Manual](/hardware/manual)
- [Security Policies](/policies/security)
- [Data Privacy Guidelines](/policies/privacy)

## 1. Introduction

### 1.1 System Overview
The Asset Management System is a comprehensive platform for tracking and managing organizational assets using RFID technology. This manual covers the web platform interface and functionality.

### 1.2 User Roles
- **Admin**: Full system access
- **Manager**: Asset and location management
- **Security**: Scanning and location-based access
- **Regular User**: Basic asset viewing and assignments

### 1.3 System Requirements
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)
- RFID Scanner hardware (supported models listed in Hardware Manual)
- Network connectivity (minimum 2Mbps)

## 2. Getting Started

### 2.1 Accessing the System
1. Navigate to the system URL
2. Click "Sign In"
3. Enter your credentials
4. System will redirect to dashboard

### 2.2 Dashboard Overview
The dashboard provides:
- Total asset count
- Investment value
- Available/In-Use assets
- Recent activity feed
- Asset distribution charts

![Dashboard Overview](./images/dashboard.png)

## 3. Asset Management

### 3.1 Viewing Assets
1. Navigate to Assets section
2. Use filters to sort by:
   - Status
   - Location
   - Category
3. Click on any asset for detailed view

### 3.2 RFID Tag Management
1. Navigate to asset details
2. Click "Assign RFID Tag"
3. Enter or scan RFID number
4. Confirm assignment

### 3.3 Asset Scanning
1. Ensure scanner is connected
2. Select correct location
3. Start scanning mode
4. Hold scanner near RFID tag
5. Verify successful scan
6. Review scan history

### 3.4 Common Error Codes
| Error Code | Description | Solution |
|------------|-------------|----------|
| SCAN-001 | Invalid RFID Tag | Verify tag is registered and active |
| SCAN-002 | Location Not Found | Select valid location from dropdown |
| SCAN-003 | Unauthorized Reader | Check reader registration status |
| AUTH-001 | Invalid Credentials | Reset password or contact admin |

## 4. Scanner Interface

### 4.1 Accessing Scanner Interface
1. Click "Scanner" in navigation menu
2. Select location from dropdown
3. System will display scanning interface

### 4.2 Scanner Status Indicators
![Scanner Interface](./images/scanner.png)

| Status | Meaning |
|--------|---------|
| 🟢 Green | Ready to scan |
| 🟡 Yellow | Processing |
| 🔴 Red | Error |

### 4.3 Scanning Process
[Previous scanning process content with added error handling from scan.html.erb]

### 4.4 Viewing Scan History
The scan history shows:
- Timestamp
- Asset details
- Location
- Event type
- Scanner device

## 5. Location Management

### 5.1 Managing Locations
1. Navigate to Locations section
2. View all locations
3. Add new location:
   - Name
   - Description
   - Parent location (optional)
   - Address details

### 5.2 Location Hierarchy
- Create parent/child relationships
- Organize by building/floor/room
- Track asset movement between locations

## 6. Reports and Analytics

### 6.1 Available Reports
- Asset Inventory
- Location History
- Maintenance Records
- Assignment History
- Scan Activity

### 6.2 Generating Reports
1. Navigate to Reports section
2. Select report type
3. Set parameters
4. Choose format (PDF, Excel, CSV)
5. Generate and download

## 7. Troubleshooting

### 7.1 Common Issues
- Login problems
- Scanning errors
- Report generation issues
- System performance

## Common Error Messages and Solutions

### API Errors
| Error | Solution |
|-------|----------|
| Insufficient scope | Request new OAuth token with correct permissions |
| Unauthorized RFID reader | Verify reader registration in admin panel |
| Invalid RFID tag | Check tag registration status |

### Scanner Errors
| Error | Solution |
|-------|----------|
| Connection failed | Check USB connection and driver status |
| Read error | Clean scanner and retry with proper distance |
| Location mismatch | Verify selected location matches physical location |

## Version History
- v1.0.0 (2024-03-20): Initial release
- v1.0.1 (2024-03-21): Added error codes section
- v1.0.2 (2024-03-22): Updated scanning process documentation

---

### 7.2 Scanner Issues
1. Check device connection
2. Verify location selection
3. Ensure proper scanning distance
4. Review error messages in status area

### 7.3 Getting Help
- Contact system administrator
- Check error messages
- Review audit logs
- Submit support ticket

## 8. Best Practices

### 8.1 Asset Management
- Regular inventory checks
- Prompt status updates
- Accurate location tracking
- Proper RFID tag placement

### 8.2 Scanning
- Maintain proper distance
- Wait for confirmation
- Verify location selection
- Review scan history

### 8.3 Data Management
- Regular backups
- Data validation
- Accurate categorization
- Proper documentation

## 9. Security Guidelines

### 9.1 Access Control
- Secure password management
- Role-based access
- Regular permission reviews
- Session management

### 9.2 Data Protection
- Confidential asset handling
- Secure scanning practices
- Protected location information
- Audit trail maintenance

## 10. Maintenance

### 10.1 System Updates
- Regular software updates
- Scanner firmware updates
- Database maintenance
- Performance optimization

### 10.2 Hardware Maintenance
- RFID scanner care
- Tag maintenance
- Battery management
- Connection verification


For technical support:
- Email: support@assetpro.com
- Phone: 1-800-ASSET-PRO
- Hours: 24/7

For system status and updates: [status.assetpro.com](https://status.assetpro.com)

