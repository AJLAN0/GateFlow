-- Gate dismissal flow: staff marks student ready for afternoon pickup / bus boarding.
ALTER TYPE student_status_enum ADD VALUE IF NOT EXISTS 'waiting_for_dismissal';
