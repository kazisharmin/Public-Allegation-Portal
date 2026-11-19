-- =============================================================
-- Demo data for the Public Allegation Portal (all fictional).
-- Run AFTER schema.sql.  Every demo account's password: Demo@1234
--   User:          demo@portal.test
--   Organization:  city@greenfield.test  (Greenfield City Corporation)
--   Private org:   registrar@northbridge.test  (Northbridge University)
-- =============================================================
SET NAMES utf8mb4;

INSERT INTO organizations (id, name, slug, email, password, address, description, access_type, status) VALUES
  (1, 'Greenfield City Corporation', 'greenfield-city-corporation', 'city@greenfield.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', '12 Station Road, Greenfield', 'Municipal services for Greenfield: waste collection, roads, street lights and drainage.', 'Public', 'active'),
  (2, 'Riverside Water Board', 'riverside-water-board', 'support@riversidewater.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', '4 Lake View Avenue, Riverside', 'Drinking water supply, pipelines and billing for the Riverside area.', 'Public', 'active'),
  (3, 'Metro Power Distribution', 'metro-power-distribution', 'care@metropower.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', '88 Grid Street, Metro City', 'Electricity distribution, meters and outage response.', 'Public', 'active'),
  (4, 'Northbridge University', 'northbridge-university', 'registrar@northbridge.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', '1 Campus Drive, Northbridge', 'A private university. Complaints are visible to members only.', 'Private', 'active');

INSERT INTO departments (id, org_id, name, slug, status) VALUES
  (1, 1, 'Waste Management', 'waste-management', 'active'),
  (2, 1, 'Roads & Street Lights', 'roads-street-lights', 'active'),
  (3, 1, 'Drainage', 'drainage', 'active'),
  (4, 2, 'Pipelines', 'pipelines', 'active'),
  (5, 2, 'Billing', 'billing', 'active'),
  (6, 3, 'Outages', 'outages', 'active'),
  (7, 3, 'Meters', 'meters', 'active'),
  (8, 4, 'Library', 'library', 'active'),
  (9, 4, 'Hostel', 'hostel', 'active'),
  (10, 4, 'IT Services', 'it-services', 'active');

INSERT INTO users (id, name, email, password, address, description) VALUES
  (1, 'Demo User', 'demo@portal.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', 'Greenfield', 'Demo account for trying the portal.'),
  (2, 'Ayesha Rahman', 'ayesha@portal.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', 'Ward 3, Greenfield', NULL),
  (3, 'Tanvir Hasan', 'tanvir@portal.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', 'Riverside', NULL),
  (4, 'Nusrat Jahan', 'nusrat@portal.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', 'Northbridge campus', 'CSE student'),
  (5, 'Rafiq Islam', 'rafiq@portal.test', '$2b$10$XCCU.EaygTWMVV3gnWsqO.x8Pfl6baNeCx1Aep85tC1IqH6pMjEPS', 'Metro City', NULL);

INSERT INTO user_organizations (user_id, org_id, role_code) VALUES
  (1, 1, 'member'),
  (1, 2, 'member'),
  (1, 4, 'member'),
  (2, 1, 'member'),
  (3, 2, 'member'),
  (3, 1, 'member'),
  (4, 4, 'member'),
  (4, 1, 'member'),
  (5, 3, 'member'),
  (5, 1, 'member');

INSERT INTO complaints (id, org_id, department_id, user_id, title, description, priority, is_anonymous, status, trackingCode, votes, createdAt) VALUES
  (1, 1, 1, 2, 'Garbage not collected for 4 days in Ward 3', 'Bins on College Road have been full since Monday and the smell is spreading to nearby houses. Please send the collection truck.', 'High', 0, 'In Progress', 'GRN4K2Q1', 4, NOW() - INTERVAL 9 DAY - INTERVAL 37 MINUTE),
  (2, 1, 2, 1, 'Street lights off on Station Road', 'About six street lights between the bus stand and the market have been off for a week. It is unsafe to walk there at night.', 'Medium', 0, 'Open', 'GRN7P1X8', 3, NOW() - INTERVAL 3 DAY - INTERVAL 74 MINUTE),
  (3, 1, 3, NULL, 'Drain overflowing after every rain', 'The drain next to the primary school overflows whenever it rains, and children have to walk through dirty water.', 'High', 1, 'Pending', 'GRN2M9D4', 4, NOW() - INTERVAL 6 DAY - INTERVAL 111 MINUTE),
  (4, 1, 2, 4, 'Large pothole near the hospital gate', 'A deep pothole at the hospital entrance is damaging rickshaws and slowing ambulances.', 'High', 0, 'Resolved', 'GRN5T3H7', 2, NOW() - INTERVAL 21 DAY - INTERVAL 148 MINUTE),
  (5, 1, NULL, 5, 'Stray dogs near the park', 'A group of stray dogs has been chasing children near Central Park in the evenings.', 'Medium', 0, 'Open', 'GRN8Q6W2', 2, NOW() - INTERVAL 1 DAY - INTERVAL 185 MINUTE),
  (6, 2, 4, 3, 'Pipeline leak on Lake View Avenue', 'Clean water has been leaking from a broken pipe for three days and the road is flooding.', 'High', 0, 'In Progress', 'RVW3L8P5', 1, NOW() - INTERVAL 4 DAY - INTERVAL 222 MINUTE),
  (7, 2, 5, 1, 'Charged twice in the October bill', 'My October water bill shows the same charge twice. I have attached the bill.', 'Low', 0, 'Resolved', 'RVW6B2N9', 0, NOW() - INTERVAL 18 DAY - INTERVAL 259 MINUTE),
  (8, 2, 4, NULL, 'Brown water from taps in the morning', 'For a week, tap water is brown for the first few minutes every morning.', 'Medium', 1, 'Open', 'RVW1C7K3', 2, NOW() - INTERVAL 2 DAY - INTERVAL 296 MINUTE),
  (9, 3, 6, 5, 'Power cut every evening 7-9 PM', 'Block C has had a two-hour power cut every evening for ten days without any notice.', 'High', 0, 'Pending', 'MTP4E9R6', 1, NOW() - INTERVAL 5 DAY - INTERVAL 333 MINUTE),
  (10, 3, 7, NULL, 'Meter reading much higher than usage', 'My prepaid meter balance drops very fast even when most appliances are off.', 'Medium', 1, 'Rejected', 'MTP9V5S1', 0, NOW() - INTERVAL 14 DAY - INTERVAL 370 MINUTE),
  (11, 4, 8, 4, 'Library closes too early during exams', 'The library closes at 6 PM even during final exams. Please extend hours to 10 PM.', 'Medium', 0, 'Resolved', 'NBU2H8J4', 1, NOW() - INTERVAL 25 DAY - INTERVAL 407 MINUTE),
  (12, 4, 9, NULL, 'No hot water in Hostel B', 'Hostel B has had no hot water for two weeks now.', 'High', 1, 'In Progress', 'NBU7F3G9', 2, NOW() - INTERVAL 7 DAY - INTERVAL 444 MINUTE),
  (13, 4, 10, 1, 'Campus Wi-Fi drops in the CSE building', 'Wi-Fi disconnects every few minutes on the 3rd and 4th floors of the CSE building, which makes online exams difficult.', 'Medium', 0, 'Open', 'NBU5Y1Z6', 1, NOW() - INTERVAL 2 DAY - INTERVAL 481 MINUTE),
  (14, 1, 1, 3, 'Overflowing bin near the bus stand', 'The public bin at the bus stand overflows every weekend.', 'Low', 0, 'Open', 'GRN3U4V8', 1, NOW() - INTERVAL 0 DAY - INTERVAL 518 MINUTE);

INSERT INTO complaint_votes (complaint_id, voter_key) VALUES
  (1, 'u:1'),
  (1, 'u:3'),
  (1, 'u:4'),
  (1, 'u:5'),
  (2, 'u:2'),
  (2, 'u:4'),
  (2, 'u:5'),
  (3, 'u:1'),
  (3, 'u:2'),
  (3, 'u:3'),
  (3, 'u:5'),
  (4, 'u:1'),
  (4, 'u:2'),
  (5, 'u:2'),
  (5, 'u:3'),
  (6, 'u:1'),
  (8, 'u:1'),
  (8, 'u:3'),
  (9, 'u:1'),
  (11, 'u:1'),
  (12, 'u:1'),
  (12, 'u:4'),
  (13, 'u:4'),
  (14, 'u:2');

INSERT INTO notifications (user_id, org_id, complaints_id, type, message, createdAt, read_at) VALUES
  (2, 1, 1, 'status_changed', 'Complaint status updated to: In Progress', NOW() - INTERVAL 7 DAY, NULL),
  (4, 1, 4, 'status_changed', 'Complaint status updated to: Resolved', NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 15 DAY),
  (3, 2, 6, 'status_changed', 'Complaint status updated to: In Progress', NOW() - INTERVAL 3 DAY, NULL),
  (1, 2, 7, 'status_changed', 'Complaint status updated to: Resolved', NOW() - INTERVAL 12 DAY, NULL),
  (4, 4, 11, 'status_changed', 'Complaint status updated to: Resolved', NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 20 DAY),
  (1, 1, 2, 'info', 'Thanks for your report. The Roads team will inspect Station Road this week.', NOW() - INTERVAL 2 DAY, NULL),
  (NULL, 1, 14, 'new_complaint', 'New complaint: Overflowing bin near the bus stand', NOW() - INTERVAL 0 DAY, NULL),
  (NULL, 1, 5, 'new_complaint', 'New complaint: Stray dogs near the park', NOW() - INTERVAL 1 DAY, NULL),
  (NULL, 2, 8, 'new_complaint', 'New complaint: Brown water from taps in the morning', NOW() - INTERVAL 2 DAY, NULL);
