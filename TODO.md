# TODO

## Future Enhancements

### Programmatic Password Change (Issue #1)

**Priority**: Medium
**Context**: First-time login and password expiration handling

**Problem**:
Eaton PDUs enforce password expiration policies. When credentials expire, users currently must:
1. Navigate to the PDU web interface
2. Manually change the password
3. Update credentials in their application

This creates friction, especially for:
- First-time setup (initial default password change)
- Automated systems that need to handle password rotation
- Multiple PDU management scenarios

**Proposed Solution**:
Add programmatic password change capability to the client:

```ruby
# Ruby API
client = Eaton::Client.new(
  host: 'pdu.example.com',
  username: 'admin',
  password: 'current_password'
)

client.change_password(new_password: 'NewSecurePass123!')

# CLI
eaton change-password \
  --host pdu.example.com \
  --username admin \
  --current-password old_pass \
  --new-password new_pass
```

**Implementation Requirements**:
1. Research Eaton PDU API endpoint for password changes
2. Implement `change_password` method in `Eaton::Client`
3. Add password policy validation before attempting change
4. Create CLI command `eaton change-password`
5. Handle special case: changing expired credentials
6. Add comprehensive error handling
7. Update documentation with password management guide
8. Add tests for password change functionality

**API Research Needed**:
- Identify correct REST endpoint (likely `/users/{id}` or `/accounts/{id}`)
- Determine if special authentication is needed for expired credentials
- Understand session requirements during password change
- Check if password history/reuse policies are enforced

**Security Considerations**:
- Never log passwords
- Clear old password from memory after use
- Validate new password against policy before submitting
- Handle authentication state correctly during transition
- Consider secure input methods (no command-line password echo)

**Testing Approach**:
- Mock API responses for password change
- Test policy validation
- Test error scenarios (wrong current password, policy violations)
- Integration test with real PDU (manual, not CI)

**Documentation Updates**:
- Add password management section to README
- Include examples for both API and CLI
- Document password policy requirements
- Add troubleshooting guide for common scenarios

**Related Files**:
- `lib/eaton/client.rb` - Add change_password method
- `lib/eaton/cli.rb` - Add CLI command
- `spec/*` - Add test coverage
- `README.md` - Update documentation
