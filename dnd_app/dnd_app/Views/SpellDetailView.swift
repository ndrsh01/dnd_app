import SwiftUI

struct SpellDetailView: View {
    let spell: Spell

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(spell.castingTime)
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "paperplane")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(spell.range)
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(spell.components)
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text(spell.duration)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 20)

            Text(spell.description)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }
}

